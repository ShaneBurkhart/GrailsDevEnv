#
# Development Env Dockerfile
#
# Sets up ssh server so you can ssh into dev env.
# Sets up VIM as well.
#
#

# Pull base image.
FROM dockerfile/ubuntu

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
  apt-get install vim git tmux
RUN \
  git clone http://github.com/ShaneBurkhart/dotfiles.git && \
  cd ~/dotfiles && ./makelinks.sh


##### Specific to your dev env (Languages) #####
RUN apt-get install wget
# Install GoLang
RUN wget -O ~/go.tar.gz https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf ~/go.tar.gz
RUN rm ~/go.tar.gz
RUN mkdir -p ~/GoWorkspace

ENV PATH $PATH:/usr/local/go/bin

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
