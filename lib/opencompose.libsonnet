local core = import "core.libsonnet";
local kubeUtil = import "util.libsonnet";

local container = core.v1.container;
local deployment = kubeUtil.app.v1beta1.deployment;
local service = core.v1.service;
local ingress = core.extensions.v1beta1.ingress;
local env = core.v1.env + kubeUtil.app.v1.env;

{
    local openlib = self,
    compact(array):: (
     [x for x in array if x != null]
    ),

    createIngress(name, params):: (
        if std.objectHas(params, "domain") then
            ingress.Default(name) +
            ingress.mixin.spec.Rule(params['domain'],
            ingress.httpIngressPath.Default(name, params['ports'][0].port))
        else
            null
    ),
     createSvc(name, params):: (
         if std.objectHas(params, 'ports') then
             service.Default(name, [params['ports'][0].port],) +
             service.mixin.spec.Selector({ app: name })
        ),

    createServices(services)::
        openlib.compact(std.flattenArrays(
            [openlib.createApp(service_name, services[service_name]),
             for service_name in std.objectFields(services)],
        )),
    createApp(name, params)::
        local containerApp =
            container.Default(name, params["image"]) +
            if std.objectHas(params, 'env') then
               container.Env(env.array.FromObj(params["env"])) else {} +
            if std.objectHas(params, 'ports') then
                container.NamedPort(params['ports'][0].name,
                    params['ports'][0].port) else {} ;

        local deployApp = deployment.FromContainer(name, 2, containerApp);
        local svcApp = openlib.createSvc(name, params);
        local ingressApp = openlib.createIngress(name, params);
        [ingressApp, svcApp, deployApp],

}
