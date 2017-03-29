FROM debian


## Add Precision RMP
#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

## Base Aptitude updates and upgrades
RUN apt-get update
RUN apt-get upgrade -y
#RUN apt-get autoremove -y

## Fix annoyances 
RUN apt-get -y remove ntpdate nano
RUN apt-get -y install ntp

## Setup locale (For SA)
#RUN apt-get install -y language-pack-UTF-8
RUN echo 'export LC_ALL="en_ZA.UTF-8";' >> /etc/profile
RUN echo 'export LC_TYPE="UTF-8";' >> /etc/profile
RUN . /etc/profile

#RUN locale-gen en_ZA
#RUN locale-gen en_ZA.UTF-8
#RUN locale

RUN apt-get -y --with-new-pkgs upgrade

RUN /etc/init.d/ntp restart
#RUN dpkg-reconfigure tzdata

RUN ln -sf /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime

## Install baremin
RUN apt-get install -y git
RUN apt-get install -y --no-install-recommends openssh-server curl wget
RUN apt-get install -y --no-install-recommends dialog
RUN apt-get install -y --no-install-recommends gnupg
RUN apt-get install -y --no-install-recommends sudo

## SSH Stuff
RUN cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults
RUN chmod a-w /etc/ssh/sshd_config.factory-defaults

RUN apt-get -y autoremove

RUN ssh-keygen -C "KEY: root @ `date`" -b 4096 -N "" -f /root/.ssh/id_rsa;

## Case specifics #START#
##############################
## [Create the root directories]
RUN mkdir /playdough
RUN mkdir -p /playdough/build/keys
RUN chmod 700 /playdough/build
RUN test -e /playdough/tmp && rm -rv /playdough/tmp; return 0;
RUN test -e /playdough/run && rm -rv /playdough/run; return 0;
RUN test -e /playdough/admin && rm -rv /playdough/admin; return 0;
RUN test -e /playdough/svc && rm -rv /playdough/svc; return 0;

## [Clone out the upstream codebase]
RUN git clone https://github.com/secd/playdough.git /playdough/svc

## [Create the project's POSFIX Groups]
RUN groupadd -g 789 g_admins
RUN groupadd -g 999 g_playdough
RUN groupadd -g 888 g_playdough_proc
RUN groupadd -g 777 g_playdough_ctl
RUN groupadd -g 555 g_playdough_noone

## [Create the project's POSFIX Users]
RUN useradd -m -c "PlayDough Procs" --uid=888 --gid=999 -N -s /bin/false -b /playdough -d /playdough/run -G g_playdough_proc,g_playdough,g_playdough_noone u_playdough_proc;

RUN useradd -c "PlayDough Message Bus" --uid=778 --gid=777 -N -s /bin/bash -b /playdough -d /playdough/run -G g_playdough_proc,g_playdough,g_playdough_ctl u_playdough_messagebus;

RUN useradd -m -c "PlayDough Admin" --uid=777 --gid=777 -N -s /bin/bash -b /playdough -d /playdough/admin -G g_playdough,g_playdough_ctl,ssh u_playdough_adm;

RUN useradd -m -c "PlayDough Data" --uid=555 --gid=999 -N -s /bin/bash -b /playdough -d /playdough/tmp -G g_playdough,g_playdough_ctl,ssh u_playdough_data;

RUN useradd -m -c "Backdoor Human" --uid=789 --gid=777 -s /bin/bash -b /playdough -d /playdough/admin -G users,g_admins,g_playdough,g_playdough_ctl,ssh u_blued;

## [Make the Project root owned by the most generic Project group]
RUN chgrp -Rv g_playdough /playdough

## [Start to prepare for the sudoers containers]
RUN mkdir -p -m 0755 /etc/sudoers.d

## Create a new sudoers definition
COPY containers/shared/etc/sudoers/playdough /etc/sudoers.d/playdough;

## [CORRECT The sudoers definition privillages] 
RUN chmod 0440 /etc/sudoers.d/playdough; return 0;

## [Create the build folder and a folder for the host users public key to be copied into]
RUN mkdir -p -m 0755 /playdough/build/keys

## [Grab a copy for the host users public key, hopefully...]
RUN touch /playdough/build/keys/user.pub
COPY "./tmp/id_rsa.pub" /playdough/build/keys/user.pub

## [Create and configure a shared OpenSSL Authorised PKI folder]
RUN mkdir -p -m 0755 /playdough/conf/access

RUN test -e /playdough/build/keys/user.pub && for UU in u_playdough_proc u_playdough_messagebus u_playdough_adm u_playdough_data u_blued; do FILESS="/playdough/conf/access/${UU}_authkey"; printf "Keying: %s -> <%s>" "$UU" "$FILESS"; cp -v /playdough/build/keys/user.pub "$FILESS";chown -v $UU:g_playdough "$FILESS"; chmod -v 600 "$FILESS";  printf "COMPLETE: %s" ; done;
# trim :: su -l -c 'if [ ! -d ~/.ssh ];then mkdir ~/.ssh;fi;chmod 700 ~/.ssh;ssh-keygen -C "KEY: ${UU} @ `date`" -b 2048 -N "" -f ~/.ssh/id_rsa' $UU;

VOLUME /playdough
WORKDIR /playdough
EXPOSE 20

#CMD /playdough/svc/shared/bin/container base
