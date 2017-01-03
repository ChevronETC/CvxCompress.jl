BUILD_HOME = pwd()

#
# clean-up after old builds
#
for dir in ("downloads", "src", "usr", "usr/lib")
    try
        run(`rm -rf $(BUILD_HOME)/$(dir)`)
        run(`mkdir -p $(BUILD_HOME)/$(dir)`)
    catch
        warn("Unable to fully clean-up from previous build, likely due to nfs")
    end
end

#
# fetch dependencies
#
run(`svn co svn+ssh://ss-svn.xhl.chevrontexaco.net/devl/geophys/src/projects/fdmod2/trunk/CvxCompress $(BUILD_HOME)/downloads/CvxCompress`)

#
# build
#
run(`cp -r $(BUILD_HOME)/downloads/CvxCompress $(BUILD_HOME)/src/`)
cd("$(BUILD_HOME)/src/CvxCompress")
run(`make -f makefile.gcc libcvxcompress.so`)
run(`mkdir -p $(BUILD_HOME)/usr/lib`)
run(`cp libcvxcompress.so $(BUILD_HOME)/usr/lib/`)
cd(BUILD_HOME)
