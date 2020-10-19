FROM ubuntu:20.04

RUN sed -i "s/http:\/\/archive.ubuntu.com/http:\/\/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list && \
    sed -i "s/http:\/\/security.ubuntu.com/http:\/\/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list && \
    dpkg --add-architecture i386 && \
    apt-get update && apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y ssh gdbserver libc6-dbg lib32z1 libc-dbg:i386 cmake libz3-dev build-essential rsync

COPY llvm-10.0.0.src.tar.xz /src/llvm-10.0.0.src.tar.xz
COPY clang-10.0.0.src.tar.xz /src/clang-10.0.0.src.tar.xz

RUN tar -xf /src/llvm-10.0.0.src.tar.xz -C /src && \
    tar -xf /src/clang-10.0.0.src.tar.xz -C /src && \
    ln -s /src/clang-10.0.0.src /src/clang && \
    mkdir /build && cd /build && \
    cmake /src/llvm-10.0.0.src -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_TARGETS_TO_BUILD=X86 \
        -DCMAKE_INSTALL_PREFIX=/llvm -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_Z3_SOLVER=ON -DLLVM_ENABLE_PROJECTS=clang && \
    make -j4 -l4 clang && make install && cd / && rm -rf /src /build

RUN sed -i -e 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i -e 's/PermitEmptyPasswords no/PermitEmptyPasswords yes/g' /etc/ssh/sshd_config && \
    sed -i -e 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i -e 's/#PermitEmptyPasswords yes/PermitEmptyPasswords yes/g' /etc/ssh/sshd_config && \
    sed -i -e 's/nullok_secure/nullok/' /etc/pam.d/common-auth && \
    passwd -d root && \
    mkdir /var/run/sshd
