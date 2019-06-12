$pkg_name="national-parks-windows"
$pkg_description="A sample JavaEE Web app deployed in the Tomcat7 package"
$pkg_origin="jmery"
$pkg_version="6.5.0"
$pkg_maintainer="Jeff Mery <jmery@chef.io>"
$pkg_license=('Apache-2.0')
$pkg_source="https://storage.googleapis.com/national-parks/$pkg_name-$pkg_version.war"
$pkg_shasum="831890bc588a739003875b4e7676c288b64338ebe6301ffaa141cbc4440d5792"
$pkg_deps=@("jmery/tomcat7","core/jre8","jmery/mongo-tools-windows")
$pkg_binds=@{
  database="port"
}
$pkg_exports=@{
  port="server.port"
}
$pkg_exposes=@{
  port="port"
}

function Invoke-Unpack {
}

function Invoke-Build {
    Copy-Item -Recurse $PLAN_CONTEXT/../data/national-parks.json $HAB_CACHE_SRC_PATH/
}

function Invoke-Install {
    Copy-Item ${HAB_CACHE_SRC_PATH}/${pkg_name}-$pkg_version.war ${PREFIX}/
    Copy-Item ${HAB_CACHE_SRC_PATH}/national-parks.json ${PREFIX}/
}
