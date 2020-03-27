# Loads a reusable pipeline task set for classic (non-ephemeral) application pipelines.
load 'pipeline-tasks/rake/app/classic.rake'

file target('dns.json')

Rake.application['server:validation:sampleapp_deployment'].clear_prerequisites
