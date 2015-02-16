#
# Development Env Dockerfile
#
# Sets up ssh server so you can ssh into dev env.
# Sets up VIM as well.
#
#

# Pull base image.
FROM niaquinto/grails

USER root
WORKDIR "/"

# Install SSH
RUN \
  apt-get update && \
  apt-get install -y openssh-server && \
  mkdir /var/run/sshd && \
  echo 'root:password' | chpasswd && \
  sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Add SHH key from host computer
RUN mkdir -p ~/.ssh
ADD ./ssh /root/.ssh

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Install VIM, TMUX and Git
RUN \
  apt-get update && \
  apt-get -y install vim git tmux mercurial meld
RUN \
  git clone http://github.com/ShaneBurkhart/dotfiles.git ~/dotfiles && \
  cd ~/dotfiles && ./makelinks.sh


##### Specific to your dev env (Languages) #####
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /root/.bashrc
RUN echo "export GRAILS_HOME=/usr/lib/jvm/grails" >> /root/.bashrc
RUN echo "export PATH=$GRAILS_HOME/bin:$PATH" >> /root/.bashrc

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd"]
CMD ["-D"]
