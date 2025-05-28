ARG PYTHON_BASE_IMAGE=quay.io/ansible/python-base:latest
ARG PYTHON_BUILDER_IMAGE=quay.io/ansible/python-builder:latest
ARG ANSIBLE_BRANCH=""
ARG ZUUL_SIBLINGS=""

FROM $PYTHON_BUILDER_IMAGE as builder
# =============================================================================
ARG ANSIBLE_BRANCH
ARG ZUUL_SIBLINGS

COPY . /tmp/src

## Need to login first with sub-manager before assembly
RUN sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/CentOS-*.repo
RUN sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/CentOS-*.repo
RUN sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/CentOS-*.repo
RUN dnf install -y subscription-manager
RUN subscription-manager register --org=$RH_ORG --activationkey=$ACTIVATION_KEY

RUN assemble

FROM $PYTHON_BASE_IMAGE
# =============================================================================

COPY --from=builder /output/ /output
RUN /output/install-from-bindep \
  && rm -rf /output
