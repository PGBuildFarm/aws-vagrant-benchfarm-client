# Recipe for and AWS instance running PostgreSQL Benchfarm Client

This vagrant recipe uses the vagrant-aws provider to set up an AWS instance of 
Scientific Linux with all the software required to run the a PGBenchfarm
client.

The client is a specially configured instance of the PostgreSQL Buildfamr 
client. There are two modifications: first the buildfamr client config must
be alterred to make it suitable for running the benchfarm module. Second, a 
special buildfarm client module is installed. All these changes can be seen in
the provisioning script.

After setting up the instance and logging in via `vagrant ssh`, you can run the
benchfarm client by running

    su - benchfarm -c ./runbench.sh

