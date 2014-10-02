
#first, handle some possible AMI idiocy

# make sure we can run sudo in batch

echo "Defaults !requiretty" > /etc/sudoers.d/50_vagrant
echo "Defaults visiblepw"  >> /etc/sudoers.d/50_vagrant

# make sure we're on the right runlevel

sed -i -e 's/id:5:initdefault:/id:3:initdefault:/' /etc/inittab
telinit 3

# install required standard software

yum install -y wget git make gcc bison flex readline-devel zlib-devel \
    openssl-devel perl-devel python-devel tcl-devel \
    perl-libwww-perl perl-Digest-SHA ccache perl-ExtUtils-Embed \
    libxml2-devel libxslt-devel openldap-devel python-dateutil15

useradd -m -c "postgresql benchfarm user" benchfarm

cat > /home/benchfarm/pgbench.conf <<-EOF
	
		     pgbench_config => [ 'SCALES="1 10 100"',
	                'SETCLIENTS="1 4 16"',
	                'SETTIMES=3'
	               ],
EOF

cat > /home/benchfarm/installbench.sh <<-EOF
	if [ ! -d buildroot ] ; then
	wget -nv http://www.pgbuildfarm.org/downloads/latest-client.tgz
	tar -z --strip-components=1 -xvf latest-client.tgz
	mkdir buildroot 
	sed -i -e 's!\(build_root =>\).*!\1 "/home/benchfarm/buildroot",!' \
	       -e 's!\(CCACHE_DIR.*\)!# \1!' \
	       -e 's!--enable-cassert!!' \
	       -e 's!\(modules =>\).*!\1 [ qw(Pgbench) ],!' \
	    build-farm.conf
	sed -i -e '/Pgbench/ r pgbench.conf' build-farm.conf

        wget -nv https://raw.githubusercontent.com/PGBuildFarm/client-code/benchfarm/PGBuild/Modules/Pgbench.pm
        mv Pgbench.pm PGBuild/Modules
	fi
	EOF

cat > /home/benchfarm/runbench.sh <<-EOF
	./run_build.pl --test --verbose --only-steps="make make-contrib install install-check"
	EOF
chown benchfarm:benchfarm /home/benchfarm/installbench.sh /home/benchfarm/runbench.sh
chmod +x /home/benchfarm/installbench.sh /home/benchfarm/runbench.sh
su - benchfarm -c ./installbench.sh



