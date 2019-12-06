FROM phusion/baseimage:0.11 as builder
LABEL maintainer "chevdor@gmail.com"
LABEL description="This image contains tools for Substrate blockchains."

ARG RUSTC_VERSION=stable
ENV PROFILE=release
ENV PACKAGE=polkadot-runtime
WORKDIR /build

# We first init as much as we can in the first layers
COPY ./scripts/init.sh /srtool/
RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install --no-install-recommends -y cmake pkg-config libssl-dev git clang bsdmainutils && \
        curl https://sh.rustup.rs -sSf | sh -s -- -y && \
        rm -rf /var/lib/apt/lists/*

RUN  export PATH=$HOME/.cargo/bin:$PATH && \
        /srtool/init.sh && \
        mv -f $HOME/.cargo/bin/* /bin && \
        rustc -V

# We copy the .cargo/bin away for 2 reasons.
# - easier with paths
# - mostly because it allows using a volume for .cargo without 'missing' the cargo bin when mapping an empty folder

RUN echo 'export PATH="/srtool/:$PATH"' >> $HOME/.bashrc
ENV PATH="/srtool:$PATH"

# we copy those only at the end which makes testing of new scripts faster as the other layers are cached
COPY ./scripts/* /srtool/ 

CMD ["/srtool/build.sh"]

# ===== SECOND STAGE ======

# FROM phusion/baseimage:0.11
# LABEL maintainer "chevdor@gmail.com"
# LABEL description="This is the 2nd stage: a very small image where we copy the Polkadot binary."
# ARG PROFILE=release
# COPY --from=builder /polkadot/target/$PROFILE/polkadot /usr/local/bin

# RUN mv /usr/share/ca* /tmp && \
# 	rm -rf /usr/share/*  && \
# 	mv /tmp/ca-certificates /usr/share/ && \
# 	rm -rf /usr/lib/python* && \
# 	useradd -m -u 1000 -U -s /bin/sh -d /polkadot polkadot && \
# 	mkdir -p /polkadot/.local/share/polkadot && \
# 	chown -R polkadot:polkadot /polkadot/.local && \
# 	ln -s /polkadot/.local/share/polkadot /data && \
# 	rm -rf /usr/bin /usr/sbin

# USER polkadot
# EXPOSE 30333 9933 9944
# VOLUME ["/data"]

# CMD ["/usr/local/bin/polkadot"]