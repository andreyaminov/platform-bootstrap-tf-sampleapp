##############################################################################################
# GENERAL CONFIGURATION
##############################################################################################

# A machine-readable name for your project.
#  - HCAP DevSecOps is able to derive other default settings from your project's name.
set :application, 'sampleapp'

# Opt out of externalized configuration.
#  - HCAP DevSecOps supports a separate config repo to avoid the need for customer forks.
#  - A future version of HCAP DevSecOps will likely convert this feature to "opt in" only.
set :external_config_type, :none

##############################################################################################
# INFRASTRUCTURE DEPLOYMENT
##############################################################################################

# Opt in to using Terraform as the infrastructure deployment tool.
#  - HCAP DevSecOps defaults to using HCAP Deploy as a deployment tool.
#  - HCAP DevSecOps also supports "per sub-project" deployment tool selection.
set :infra_deploy_tool, :terraform

# Where should Terraform store it's state?
#  - HCAP DevSecOps can automatically configure Terraform remote state,
#    using AWS S3, Azure Blob, or your local machine.
set :terraform_backend_bucket, 'rean-ciinfra-reanplatform'

# A list of machine-readable sub-project names.  Each one represents an infrastructure
# sub-project to be deployed, regardless of the deployment tool being used.
#  - HCAP DevSecOps is able to derive many other default settings from a sub-project name.
#  - When you select Terraform as your deployment tool, the default sub-project directory
#    will be `terraform/MY-SUBPROJECT-NAME`.
set :infra_envs, [
  :sampleapp_aks_lb,
  :sampleapp_dns
]

# What input variables should be passed to the :sampleapp_aks_lb Terraform project?
#
#  - HCAP DevSecOps allows you to dynamically define the values of input variables,
#    based on any logic that you can define using Ruby.
#  - HCAP DevSecOps allows you to "lazily" declare the values of input variables,
#    so that they are not calculated until the exact time that they are needed.
set :sampleapp_aks_lb_vars do
  {
    kube_config_file: env!('KUBECONFIG'),
    #                 ^^^
    #                 HCAP DevSecOps allows you to explicitly throw an error when a required
    #                 environment variable does not exist.
    kube_context: 'frezbo-aks-k8s',
    namespace: 'rean-ciinfra-reanplatform'
  }
end

# What input variables should be passed to the :sampleapp_dns Terraform project?
#
#  - HCAP DevSecOps allows you to dynamically define the values of input variables,
#    based on any logic that you can define using Ruby.
#  - HCAP DevSecOps allows you to "lazily" declare the values of input variables,
#    so that they are not calculated until the exact time that they are needed.
set :sampleapp_dns_vars do
  {
      dns_record: terraform_output('infra-sampleapp_aks_lb.json', 'lb_ip').call
      #           ^^^
      #           HCAP DevSecOps supports lazily loading any Terraform outputs for use in your
      #           pipeline configuration logic.  You can also use an output "right away" by
      #           calling the `call` method on the return value.
  }
end

##############################################################################################
# APPLICATION DEPLOYMENT
##############################################################################################

# Opt in to using Terraform as the application deployment tool.
#  - HCAP DevSecOps defaults to using HCAP Deploy as a deployment tool.
#  - HCAP DevSecOps also supports "per sub-project" deployment tool selection.
set :app_deploy_tool, :terraform

# A list of machine-readable sub-project names.  Each one represents an application
# sub-project to be deployed, regardless of the deployment tool being used.
#  - HCAP DevSecOps is able to derive many other default settings from a sub-project name.
#  - When you select Terraform as your deployment tool, the default sub-project directory
#    will be `terraform/MY-SUBPROJECT-NAME`.
set :app_envs, [
  :sampleapp_deployment
]

# What input variables should be passed to the :sampleapp_deployment Terraform project?
#
#  - HCAP DevSecOps allows you to dynamically define the values of input variables,
#    based on any logic that you can define using Ruby.
#  - HCAP DevSecOps allows you to "lazily" declare the values of input variables,
#    so that they are not calculated until the exact time that they are needed.
set :sampleapp_deployment_vars do
  {
    username: ENV['ARTIFACTORY_USERNAME'],
    password: ENV['ARTIFACTORY_API_KEY'],
    #         ^^^
    #         HCAP DevSecOps supports loading configuration values from environment variables,
    #         which can be especially handy when dealing with secrets that you don't want to
    #         check into a git repository.  Secrets can also be loaded from AWS SSM.
    helm_chart_version: '0.1.4',
    ingress_class: 'platform-nginx',
    ingress_controller_name: 'ingress-nginx-ingress-controller',
    ingress_host: 'sampleapp.itsreaning.com',
    kube_config_file: env!('KUBECONFIG'),
    #                 ^^^
    #                 HCAP DevSecOps allows you to explicitly throw an error when a required
    #                 environment variable does not exist.
    kube_context: 'frezbo-aks-k8s',
    namespace: 'rean-ciinfra-reanplatform'
  }
end

##############################################################################################
# SERVER VALIDATION
##############################################################################################

# What server should be tested by inspec?
#  - HCAP DevSecOps supports a simple syntax for declaring servers to be tested by Inspec.
#  - The machine-readable name for your server is used as a "prefix" for loading any other
#    configuration options that you would like to apply to your inspec tests.
server :sampleapp_deployment, protocol: 'local', host: 'localhost', test_profile: 'sampleapp'

# What inspec input attributes should be passed to the :sampleapp_deployment server tests?
#
#  - HCAP DevSecOps allows you to dynamically define the values of inspec attributes,
#    based on any logic that you can define using Ruby.
#  - HCAP DevSecOps allows you to "lazily" declare the values of inspec attributes,
#    so that they are not calculated until the exact time that they are needed.
set :sampleapp_deployment_inspec_inputs do
  {
    kube_config_file: env!('KUBECONFIG'),
    #                 ^^^
    #                 HCAP DevSecOps allows you to explicitly throw an error when a required
    #                 environment variable does not exist.
    kube_context: 'frezbo-aks-k8s',
    namespace: 'rean-ciinfra-reanplatform'
  }
end

##############################################################################################
# APPLICATION TESTING
##############################################################################################


# What website should be tested by HCAP Test?
#  - HCAP DevSecOps supports a simple syntax for declaring websites to be tested by HCAP Test.
#  - HCAP DevSecOps will default to running all declared functional tests and load tests against
#    all declared websites, unless you specifically declare which tests to run against which websites.
website :sampleapp, protocol: :https, host: 'sampleapp.itsreaning.com'

# A list of HCAP Test functional tests to be run, with a minimal number of options required.
#  - HCAP DevSecOps automatically applies default test execution options to each test in the list below,
#    unless you specifically provide an alternative value.
#  - HCAP DevSecOps automatically loads Git credentials from the GIT_USER and GIT_PASS environment
#    variables, unless you specifically provide alternative values.
set :functional_tests, [
  {
    git_repository_url: 'https://github.com/reancloud/selenium-spring-application.git',
    command_to_run_test: 'mvn test -Dcucumber.options="--tags @app_test"',
    chrome: '72',
    firefox: '63',
    wait: true
  }
]

# A list of HCAP Test load tests to be run, with a minimal number of options required.
#  - HCAP DevSecOps automatically applies default test execution options to each test in the list below,
#    unless you specifically provide an alternative value.
#  - HCAP DevSecOps automatically loads Git credentials from the GIT_USER and GIT_PASS environment
#    variables, unless you specifically provide alternative values.
set :load_tests, [
  {
    git_repository_url: 'https://github.com/reancloud/selenium-spring-application.git',
    command_to_run_test: 'mvn test -Dcucumber.options="--tags @app_test"',
    chrome: '72',
    firefox: '63',
    wait: true
  }
]
