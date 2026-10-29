// Placement probe: every OpenMP thread of every rank reports its host, the CPU
// it is running on, and how many CPUs its affinity mask allows. Rank 0 prints
// the map and checks, per host, that
//   - no two threads were observed on the same CPU (no oversubscription), and
//   - with binding requested (PLACEMENT_EXPECT_BOUND=1), each thread's mask is
//     a single core's worth of CPUs, not the whole node.
// Linux only (sched_getcpu, sched_getaffinity).
#include <mpi.h>
#include <omp.h>
#include <sched.h>
#include <unistd.h>

#include <cstdio>
#include <cstdlib>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace {

struct Sample {
    int rank, thread, cpu, mask_cpus;
    char host[64];
};

// Spin briefly so threads are actually running concurrently when sampled.
void busy(double seconds) {
    const double t0 = omp_get_wtime();
    volatile double x = 0.0;
    while (omp_get_wtime() - t0 < seconds) x += 1.0;
}

}  // namespace

int main(int argc, char **argv) {
    int provided = 0;
    MPI_Init_thread(&argc, &argv, MPI_THREAD_FUNNELED, &provided);
    int rank = 0, size = 1;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    char host[64] = {0};
    gethostname(host, sizeof host - 1);
    const int threads = omp_get_max_threads();
    std::vector<Sample> mine(threads);
#pragma omp parallel num_threads(threads)
    {
        busy(0.2);
        cpu_set_t mask;
        CPU_ZERO(&mask);
        sched_getaffinity(0, sizeof mask, &mask);
        Sample &s = mine[omp_get_thread_num()];
        s.rank = rank;
        s.thread = omp_get_thread_num();
        s.cpu = sched_getcpu();
        s.mask_cpus = CPU_COUNT(&mask);
        std::snprintf(s.host, sizeof s.host, "%s", host);
        busy(0.2);
    }

    const int bytes = static_cast<int>(threads * sizeof(Sample));
    std::vector<Sample> all(rank == 0 ? static_cast<std::size_t>(size) * threads : 0);
    MPI_Gather(mine.data(), bytes, MPI_BYTE, all.data(), bytes, MPI_BYTE, 0, MPI_COMM_WORLD);

    int ok = 1;
    if (rank == 0) {
        const char *expect = std::getenv("PLACEMENT_EXPECT_BOUND");
        const bool expect_bound = expect && std::string(expect) == "1";
        const long online = sysconf(_SC_NPROCESSORS_ONLN);
        std::map<std::string, std::set<int>> cpus_per_host;
        std::map<std::string, int> threads_per_host;
        int max_mask = 0;
        for (const Sample &s : all) {
            std::printf("placement host=%s rank=%d thread=%d cpu=%d mask_cpus=%d\n", s.host, s.rank,
                        s.thread, s.cpu, s.mask_cpus);
            cpus_per_host[s.host].insert(s.cpu);
            ++threads_per_host[s.host];
            if (s.mask_cpus > max_mask) max_mask = s.mask_cpus;
        }
        for (const auto &h : threads_per_host) {
            const int distinct = static_cast<int>(cpus_per_host[h.first].size());
            if (distinct != h.second) ok = 0;
            std::printf("placement_host host=%s threads=%d distinct_cpus=%d\n", h.first.c_str(),
                        h.second, distinct);
        }
        // A bound thread may own one core's hardware threads (SMT), never more
        // than a few CPUs; an unbound one sees the whole cpuset.
        if (expect_bound && max_mask > 2) ok = 0;
        // Multi-node jobs: ranks must actually be spread over the expected hosts.
        const char *hosts_env = std::getenv("PLACEMENT_EXPECT_HOSTS");
        const int want_hosts = hosts_env ? std::atoi(hosts_env) : 0;
        if (want_hosts > 0 && static_cast<int>(threads_per_host.size()) != want_hosts) ok = 0;
        std::printf("placement_hosts distinct=%zu expected=%d\n", threads_per_host.size(), want_hosts);
        std::printf("placement_check ranks=%d threads=%d online_cpus=%ld max_mask_cpus=%d "
                    "expect_bound=%d %s\n",
                    size, threads, online, max_mask, expect_bound ? 1 : 0, ok ? "PASS" : "FAIL");
    }
    MPI_Bcast(&ok, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Finalize();
    return ok ? 0 : 1;
}
