# frozen_string_literal: true

# Set local VirusScanner
Hydra::Works.default_system_virus_scanner = Hyrax::VirusScanner

if defined?(Clamby)
  Clamby.configure(
    check: false,
    # daemonize: true,
    output_level: 'medium',
    fdpass: true
  )
end
