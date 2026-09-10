FROM registry.fedoraproject.org/fedora:44

RUN dnf install -y \
    git \
    rsync \
    openssh-clients \
    python3.9 \
    python3.9-devel \
    gcc \
    publican \
    libxslt \
    libxml2 \
    docbook-dtds \
    make \
    ruby \
    ruby-devel \
    && dnf clean all

# Pin asciidoctor to 2.0.20 — the same version used by the Prow CI container
# (quay.io/redhat-docs/openshift-docs-asciidoc). Fedora 44 ships 2.0.26, which
# introduced a new ERROR for incomplete table rows (asciidoctor#4573, released
# in 2.0.23) that causes Aura's _build_docbook_src to return False on valid
# source files that the Prow container builds without issue.
RUN gem install asciidoctor -v 2.0.20 --no-document && \
    gem install asciidoctor-diagram --no-document

COPY aura.tar.gz /tmp/
RUN python3.9 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools==68.2.2 wheel && \
    /opt/venv/bin/pip install pyyaml && \
    /opt/venv/bin/pip install /tmp/aura.tar.gz && \
    rm /tmp/aura.tar.gz && \
    sed -i 's|print(line.replace("\\n", ""))|print(line.replace("\\n", ""))\n\n        import fileinput\n        fileinput.close()|' /opt/venv/lib/python3.9/site-packages/aura/transformers/tf_asciidoc.py

ENV PATH="/opt/venv/bin:$PATH"
ENV XML_CATALOG_FILES="/etc/xml/catalog"

WORKDIR /workspace

CMD ["/bin/bash"]
