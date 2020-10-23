FROM quay.io/openshift/origin-jenkins-agent-base as jenkins-base 

FROM registry.access.redhat.com/ubi8/ubi

COPY --from=jenkins-base /usr/bin/go-init /usr/bin/go-init
COPY --from=jenkins-base /usr/local/bin /usr/local/bin

ENV HOME=/home/jenkins \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

USER root
# Install headless Java
RUN INSTALL_PKGS="bc gettext git java-11-openjdk-headless java-1.8.0-openjdk-headless lsof rsync tar unzip which zip bzip2 jq" && \
    yum install -y --setopt=tsflags=nodocs --disableplugin=subscription-manager $INSTALL_PKGS && \
    rpm -V  $INSTALL_PKGS && \
    yum clean all && \
    mkdir -p /home/jenkins && \
    chown -R 1001:0 /home/jenkins && \
    chmod -R g+w /home/jenkins && \
    chmod -R 775 /etc/alternatives && \
    chmod -R 775 /var/lib/alternatives && \
    chmod -R 775 /usr/lib/jvm && \
    chmod 775 /usr/bin && \
    chmod 775 /usr/share/man/man1 && \
    mkdir -p /var/lib/origin && \
    chmod 775 /var/lib/origin && \    
    unlink /usr/bin/java && \
    unlink /usr/bin/jjs && \
    unlink /usr/bin/keytool && \
    unlink /usr/bin/pack200 && \
    unlink /usr/bin/rmid && \
    unlink /usr/bin/rmiregistry && \
    unlink /usr/bin/unpack200 && \
    unlink /usr/share/man/man1/java.1.gz && \
    unlink /usr/share/man/man1/jjs.1.gz && \
    unlink /usr/share/man/man1/keytool.1.gz && \
    unlink /usr/share/man/man1/pack200.1.gz && \
    unlink /usr/share/man/man1/rmid.1.gz && \
    unlink /usr/share/man/man1/rmiregistry.1.gz && \
    unlink /usr/share/man/man1/unpack200.1.gz

RUN INSTALL_PKGS="python38 python38-devel python38-setuptools python38-pip \
        nss_wrapper httpd httpd-devel mod_ssl mod_auth_gssapi \
        mod_ldap mod_session atlas-devel gcc-gfortran libffi-devel \
        libtool-ltdl enchant glibc-langpack-en redhat-rpm-config" && \
    yum -y module enable python38:3.8 httpd:2.4 && \
    yum -y --setopt=tsflags=nodocs install --disableplugin=subscription-manager $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    # Remove redhat-logos-httpd (httpd dependency) to keep image size smaller.
    rpm -e --nodeps redhat-logos-httpd && \
    yum -y clean all --enablerepo='*'

ENTRYPOINT ["/usr/bin/go-init", "-main", "/usr/local/bin/run-jnlp-client"]