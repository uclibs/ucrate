var ls = function() {
      $('<a href="#" id="license-wizard" class="pull-right btn btn-success selector">License Wizard</a>')
      .insertBefore('.rights-selector')
      .licenseSelector({
        // Options

        start: 'KindOfContent',

        // Define custom licenses

        licenses: {
          'all-rights-reserved': {
            name: 'All rights reserved',
            priority: 1,
            available: true,
            url: 'http://www.europeana.eu/portal/rights/rr-r.html',
            description: '\"All rights reserved\" is a phrase that originated in copyright law as a formal requirement for copyright notice. It indicates that the copyright holder reserves, or holds for their own use, all the rights provided by copyright law under one specific copyright treaty.',
            categories: ['reserved', 'by', 'nd', 'nc'],
            labels: ['reserved'],
          },

          // Remove default licenses from plugin (most are cc-4.0 and software oriented)

          'cc-zero': {name: 'CC0 1.0 Universal', labels: ['pd']},
          'odbl': {available: true, categories: ['dataset', 'data_by', 'data_sa'], url: 'http://opendatacommons.org/licenses/dbcl/1.0/', description: 'The ODbL allows freedom of use while requiring attribution and release of derivatives under the same license.', name: 'Open Data Commons Open Database License (ODbL)'},
          'pddl': {available: true, categories: ['dataset','data_public-domain'], description: 'The PDDL places the data(base) in the public domain (waiving all rights)', name: 'Open Data Commons Public Domain Dedication and License (PDDL)', url: 'http://www.opendatacommons.org/licenses/pddl/1.0/'},
          'odc-by': {available: true, categories: ['dataset', 'data_by'], url: 'http://www.opendatacommons.org/licenses/by/1.0/', description: 'A license specific to data(bases) used to provide freedom of use while only requiring attribution of the database', name: 'Open Data Commons Attribution License (ODC-By)'},
          'cc-public-domain': {name: 'Public Domain Mark 1.0', labels: ['pd','']},
          'perl-artistic-1': {available: false},
          'perl-artistic-2': {available: false},
          'gpl-2': {available: false},
          'gpl-2+': {available: false},
          'gpl-3': {available: false},
          'agpl-3': {available: false},
          'epl-1': {available: false},
          'cddl-1': {available: false},
          'lgpl-2.1+': {available: false},
          'lgpl-3': {available: false},
          'mpl-2': {available: false},
          'mit': {available: false},
          'apache-2': {available: false},
          'bsd-2c': {available: false},
          'bsd-3c': {available: false},

        },
            onLicenseSelected : function (license) {
              var license_uri = license.url;
              $('body').scrollTop( scrollTop );
              $('.rights-selector option[value="' + license_uri + '"]').prop('selected', true);
              $('.rights-selector').effect( 'highlight',{color: '#ADD8E6'}, 1500 );
            }
          })
        .on('click', function() { scrollTop = $('body').scrollTop();})
        }
  $(document).on('turbolinks:load', ls);
  
