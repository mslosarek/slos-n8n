const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');
const deasync = require('deasync');

const ssm = new SSMClient({
  region: process.env.AWS_REGION || 'us-west-2'
});

function getSSMParamSync(paramName, defaultValue) {
  let result = defaultValue;
  let done = false;

  const command = new GetParameterCommand({
    Name: paramName,
    WithDecryption: true,
  });

  ssm.send(command)
    .then(response => {
      result = response.Parameter.Value;
      console.log(`Successfully retrieved ${paramName}`);
      done = true;
    })
    .catch(error => {
      console.warn(`Failed to get parameter ${paramName}:`, error);
      done = true;
    });

  deasync.loopWhile(() => !done);
  return result;
}

function getEnvVarsSync() {
  console.log('Loading environment variables from SSM...');
  const envVars = {
    N8N_HOST: getSSMParamSync('/n8n/slos/host', 'localhost'),
    N8N_PORT: getSSMParamSync('/n8n/slos/port', '5678'),
    N8N_PROTOCOL: getSSMParamSync('/n8n/slos/protocol', 'http'),
    WEBHOOK_URL: getSSMParamSync('/n8n/slos/webhook-url', 'https://n8n.slos.io'),
    N8N_USER_MANAGEMENT_DISABLED: getSSMParamSync('/n8n/slos/user-management-disabled', 'true'),
    N8N_DIAGNOSTICS_ENABLED: getSSMParamSync('/n8n/slos/diagnostics-enabled', 'false'),
    N8N_HIRING_BANNER_ENABLED: getSSMParamSync('/n8n/slos/hiring-banner-enabled', 'false'),
    N8N_PERSONALIZATION_ENABLED: getSSMParamSync('/n8n/slos/personalization-enabled', 'false'),
    N8N_EMAIL_MODE: getSSMParamSync('/n8n/slos/email-mode', 'smtp'),
    NODE_ENV: getSSMParamSync('/n8n/slos/node-env', 'production'),
    N8N_RUNNERS_ENABLED: getSSMParamSync('/n8n/slos/runners-enabled', 'true'),
    DB_TYPE: 'postgresdb',
    DB_POSTGRESDB_DATABASE: getSSMParamSync('/n8n/slos/db_name', 'postgres'),
    DB_POSTGRESDB_HOST: getSSMParamSync('/n8n/slos/db_host', ''),
    DB_POSTGRESDB_PORT: getSSMParamSync('/n8n/slos/db_port', '5432'),
    DB_POSTGRESDB_USER: getSSMParamSync('/n8n/slos/db_user', 'postgres'),
    DB_POSTGRESDB_PASSWORD: getSSMParamSync('/n8n/slos/db_password', ''),
    DB_POSTGRESDB_SCHEMA: 'public',
    DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED: 'false',
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS: 'true'
  };
  console.log('Environment variables loaded:', Object.keys(envVars));
  return envVars;
}

// Always load environment variables
const envVars = getEnvVarsSync();

module.exports = {
  apps: [{
    name: "n8n",
    script: "node_modules/n8n/bin/n8n",
    env: envVars,
    env_production: {
      ...envVars,  // Include all environment variables in production
      NODE_ENV: "production"
    },
    watch: false,
    max_memory_restart: "1G",
    error_file: "logs/n8n-error.log",
    out_file: "logs/n8n-out.log",
    log_date_format: "YYYY-MM-DD HH:mm:ss",
    merge_logs: true
  }],
  deploy: {
    production: {
      user: "ec2-user",
      host: "n8n.slos.io",
      key: "~/.ssh/slos-n8n.pem",
      ref: "origin/main",
      repo: "git@github.com:mslosarek/slos-n8n.git",
      path: "/home/ec2-user/app",
      "pre-deploy-local": "echo 'Starting deployment...'",
      "pre-deploy": "cd /home/ec2-user/app/source && mkdir -p /home/ec2-user/app/source",
      "post-deploy": "cd /home/ec2-user/app/source && npm install && NODE_ENV=production node ecosystem.config.js && pm2 reload ecosystem.config.js --env production",
      "ssh_options": ["StrictHostKeyChecking=no", "UserKnownHostsFile=/dev/null"],
      "pre-setup": "mkdir -p /home/ec2-user/.ssh && chmod 700 /home/ec2-user/.ssh",
      "post-setup": "cd /home/ec2-user/app/source && git config --global --add safe.directory /home/ec2-user/app/source"
    }
  }
};
