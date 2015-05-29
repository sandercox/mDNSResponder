#!/bin/bash

# Import a source dump from http://www.opensource.apple.com/tarballs/mDNSResponder/ into a new versioned revision
# in this repository.

## initial import
# ./import_sourcetree.sh ../mDNSResponder-22.tar.gz ../mDNSResponder-25.tar.gz ../mDNSResponder-26.2.tar.gz ../mDNSResponder-58.tar.gz ../mDNSResponder-58.1.tar.gz ../mDNSResponder-58.3.tar.gz ../mDNSResponder-58.5.tar.gz ../mDNSResponder-58.6.tar.gz ../mDNSResponder-58.8.tar.gz ../mDNSResponder-58.8.1.tar.gz ../mDNSResponder-66.3.tar.gz ../mDNSResponder-87.tar.gz ../mDNSResponder-98.tar.gz ../mDNSResponder-107.tar.gz ../mDNSResponder-107.1.tar.gz ../mDNSResponder-107.3.tar.gz ../mDNSResponder-107.4.tar.gz ../mDNSResponder-107.5.tar.gz ../mDNSResponder-107.6.tar.gz ../mDNSResponder-108.tar.gz ../mDNSResponder-108.2.tar.gz ../mDNSResponder-108.4.tar.gz ../mDNSResponder-108.5.tar.gz ../mDNSResponder-108.6.tar.gz ../mDNSResponder-161.1.tar.gz ../mDNSResponder-164.tar.gz ../mDNSResponder-170.tar.gz ../mDNSResponder-171.4.tar.gz ../mDNSResponder-176.2.tar.gz ../mDNSResponder-176.3.tar.gz ../mDNSResponder-212.1.tar.gz ../mDNSResponder-214.tar.gz ../mDNSResponder-214.3.tar.gz ../mDNSResponder-214.3.2.tar.gz ../mDNSResponder-258.13.tar.gz ../mDNSResponder-258.14.tar.gz ../mDNSResponder-258.18.tar.gz ../mDNSResponder-258.21.tar.gz ../mDNSResponder-320.5.tar.gz ../mDNSResponder-320.5.1.tar.gz ../mDNSResponder-320.10.tar.gz ../mDNSResponder-320.10.80.tar.gz ../mDNSResponder-320.14.tar.gz ../mDNSResponder-320.16.tar.gz ../mDNSResponder-320.18.tar.gz ../mDNSResponder-333.10.tar.gz ../mDNSResponder-379.27.tar.gz ../mDNSResponder-379.27.1.tar.gz ../mDNSResponder-379.32.1.tar.gz ../mDNSResponder-379.37.tar.gz ../mDNSResponder-379.38.1.tar.gz ../mDNSResponder-522.1.11.tar.gz ../mDNSResponder-522.90.2.tar.gz ../mDNSResponder-522.92.1.tar.gz ../mDNSResponder-541.tar.gz ../mDNSResponder-544.tar.gz ../mDNSResponder-561.1.1.tar.gz ../mDNSResponder-567.tar.gz

FILES=$*
MYDIR=${PWD}

for F in ${FILES}; do
  echo "Processing ${F}..."
  PARTS=(`echo ${F%.tar.gz} | tr '-' ' '`)
  VERSION=${PARTS[1]}
  pushd /tmp
  echo "Unpacking ${F}..."
  tar xzf "${MYDIR}/${F}"
  
  FILENAME=${F%.tar.gz}
  SOURCEPATH=/tmp/$(basename ${FILENAME})
  popd;
  
  echo "Syncing changes..."
  rsync -a --delete --exclude '.git' --exclude 'import_sourcetree.sh' "${SOURCEPATH}/" .
  
  echo "Commit to git..."
  git add *
  git add -u
  git commit -m "Version ${VERSION}" .

  TAG_VERSION=${VERSION}
  VERSION_PARTS=(`echo ${VERSION} | tr '.' ' '`)
  if [ ${#VERSION_PARTS[@]} == 2 ]; then
    TAG_VERSION=${VERSION}.0
  elif [ ${#VERSION_PARTS[@]} == 1 ]; then
    TAG_VERSION=${VERSION}.0.0
  fi;

  echo "Creating tag v{$TAG_VERSION}..."  
  git tag -a v${TAG_VERSION} -m "Version ${V}"
  
  echo "Removing files from archive..."
  rm -rf "${SOURCEPATH}"
  echo "Done processing ${F}."
done;
