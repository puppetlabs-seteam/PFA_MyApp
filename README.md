# Sample App for Puppet Pipelines for Applications

Installs MySQL, Nginx, PHP and a PHP website that stores and retrieves images from a database.

Uses Puppet Bolt Tasks and Plans with the new Apply() function to quickly provision all the software, leveraging existing Puppet modules from the Forge.

To deploy:
- Add to PFA (tick the box for the distelli-manifest, select "Pipelines PHP" for build image)
- Deploy onto t2.micro RHEL/CentOS servers in Amazon (template already available in the seteam account) 
- View deploy log to get the URL to visit with your browser
