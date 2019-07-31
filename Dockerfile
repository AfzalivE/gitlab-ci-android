#
# GitLab CI: Android v0.2
#
# https://hub.docker.com/r/jangrewe/gitlab-ci-android/
# https://git.faked.org/jan/gitlab-ci-android
#
#
FROM openjdk:8-jdk
MAINTAINER Jan Grewe <jan@faked.org>

ENV VERSION_SDK_TOOLS "4333796"
ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools"

RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes --no-install-recommends \
      lib32stdc++6 \
      curl \
      git-core \
      html2text \
      libc6-i386 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      locales \
      build-essential \
      ruby \
      ruby-dev \
      vim-common \
      wget
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > /sdk.zip
RUN unzip /sdk.zip -d /sdk
RUN rm -v /sdk.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_HOME/licenses/android-sdk-preview-license

ADD packages.txt /sdk
RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  ${ANDROID_HOME}/tools/bin/sdkmanager --update

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt && \
    ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses
