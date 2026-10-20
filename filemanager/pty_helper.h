#ifndef RAD_PTY_HELPER_H
#define RAD_PTY_HELPER_H

#if defined(__APPLE__) || defined(__linux__)
#if defined(__APPLE__)
#include <util.h>
#else
#include <pty.h>
#endif
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <termios.h>
#include <errno.h>

static int rad_pty_spawn(const char* shell_path, const char* cwd, int cols, int rows, int* out_pid) {
    struct winsize ws;
    memset(&ws, 0, sizeof(ws));
    ws.ws_col = (unsigned short)(cols > 0 ? cols : 100);
    ws.ws_row = (unsigned short)(rows > 0 ? rows : 28);

    int master_fd = -1;
    pid_t pid = forkpty(&master_fd, NULL, NULL, &ws);
    if (pid < 0) {
        return -1;
    }
    if (pid == 0) {
        if (cwd && cwd[0] != '\0') {
            if (chdir(cwd) != 0) {
                const char* home = getenv("HOME");
                if (home) {
                    (void)chdir(home);
                }
            }
        }
        setenv("TERM", "xterm-256color", 1);
        setenv("COLORTERM", "truecolor", 1);
        setenv("TERM_PROGRAM", "CodecaineFileManager", 1);
        const char* sh = (shell_path && shell_path[0] != '\0') ? shell_path : "/bin/zsh";
        execl(sh, sh, "-l", (char*)NULL);
        execl("/bin/sh", "/bin/sh", (char*)NULL);
        _exit(127);
    }
    int flags = fcntl(master_fd, F_GETFL, 0);
    if (flags >= 0) {
        fcntl(master_fd, F_SETFL, flags | O_NONBLOCK);
    }
    int fd_flags = fcntl(master_fd, F_GETFD, 0);
    if (fd_flags >= 0) {
        fcntl(master_fd, F_SETFD, fd_flags | FD_CLOEXEC);
    }
    if (out_pid) {
        *out_pid = (int)pid;
    }
    return master_fd;
}

static int rad_pty_read(int master_fd, unsigned char* buf, int cap) {
    if (master_fd < 0 || !buf || cap <= 0) return -2;
    ssize_t n = read(master_fd, buf, (size_t)cap);
    if (n > 0) return (int)n;
    if (n == 0) return -2;
    if (errno == EAGAIN || errno == EWOULDBLOCK || errno == EINTR) {
        return 0;
    }
    return -2;
}

static int rad_pty_write(int master_fd, const char* data, int len) {
    if (master_fd < 0 || !data || len <= 0) return 0;
    int total = 0;
    int retries = 0;
    while (total < len) {
        ssize_t w = write(master_fd, data + total, (size_t)(len - total));
        if (w > 0) {
            total += (int)w;
            retries = 0;
        } else if (w < 0 && (errno == EAGAIN || errno == EWOULDBLOCK || errno == EINTR)) {
            if (++retries > 50) break;
            usleep(1000);
        } else {
            break;
        }
    }
    return total;
}

static void rad_pty_resize(int master_fd, int cols, int rows) {
    if (master_fd < 0) return;
    struct winsize ws;
    memset(&ws, 0, sizeof(ws));
    ws.ws_col = (unsigned short)(cols > 0 ? cols : 100);
    ws.ws_row = (unsigned short)(rows > 0 ? rows : 28);
    ioctl(master_fd, TIOCSWINSZ, &ws);
}

static int rad_pty_check_exit(int pid, int* out_code) {
    if (pid <= 0) return 1;
    int status = 0;
    pid_t res = waitpid((pid_t)pid, &status, WNOHANG);
    if (res == (pid_t)pid) {
        if (out_code) {
            if (WIFEXITED(status)) *out_code = WEXITSTATUS(status);
            else if (WIFSIGNALED(status)) *out_code = 128 + WTERMSIG(status);
            else *out_code = 0;
        }
        return 1;
    }
    if (res < 0 && errno == ECHILD) {
        if (out_code) *out_code = 0;
        return 1;
    }
    return 0;
}

static void rad_pty_close(int master_fd, int pid) {
    if (master_fd >= 0) {
        close(master_fd);
    }
    if (pid > 0) {
        kill(-(pid_t)pid, SIGHUP);
        kill((pid_t)pid, SIGHUP);
        int status = 0;
        (void)waitpid((pid_t)pid, &status, WNOHANG);
    }
}

#else

static int rad_pty_spawn(const char* shell_path, const char* cwd, int cols, int rows, int* out_pid) {
    (void)shell_path; (void)cwd; (void)cols; (void)rows;
    if (out_pid) *out_pid = -1;
    return -1;
}
static int rad_pty_read(int master_fd, unsigned char* buf, int cap) {
    (void)master_fd; (void)buf; (void)cap;
    return -2;
}
static int rad_pty_write(int master_fd, const char* data, int len) {
    (void)master_fd; (void)data; (void)len;
    return 0;
}
static void rad_pty_resize(int master_fd, int cols, int rows) {
    (void)master_fd; (void)cols; (void)rows;
}
static int rad_pty_check_exit(int pid, int* out_code) {
    (void)pid;
    if (out_code) *out_code = 0;
    return 1;
}
static void rad_pty_close(int master_fd, int pid) {
    (void)master_fd; (void)pid;
}

#endif

#endif // RAD_PTY_HELPER_H
