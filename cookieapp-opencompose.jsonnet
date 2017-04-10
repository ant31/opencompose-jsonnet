local opencompose = import "lib/opencompose.libsonnet";

function(params={}, namespace="default")

opencompose.createServices({

 web: {
         image: "quay.io/ant31/cookiapp:0.5.0",
         domain: "cookieapp.kubespray.com",
         env: {"database": "postgresql.%s.svc.cluster.local" % namespace},
         ports: [{name: "http", port: 80}],
      },

database: {
            image: "postgresql:latest",
            ports: [{name: "pg", port: 5432, expose: false}]
         },

})

