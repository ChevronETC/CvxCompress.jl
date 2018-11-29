BUILD_HOME = pwd()
REPO_PATH = haskey(ENV, "CODE_REPO_PATH") ? "$(ENV["CODE_REPO_PATH"])/CvxCompress" : "https://chevron.visualstudio.com/ETC-ESD-CvxCompress/_git/CvxCompress"

#
# clean-up after old builds
#
for dir in ("downloads", "src", "usr", "usr/lib")
    try
        run(`rm -rf $(BUILD_HOME)/$(dir)`)
        run(`mkdir -p $(BUILD_HOME)/$(dir)`)
    catch
        @warn "Unable to fully clean-up from previous build, likely due to nfs"
    end
end

#
# fetch dependencies
#
run(`git clone $(REPO_PATH) $(BUILD_HOME)/downloads/CvxCompress`)
cd("$(BUILD_HOME)/downloads/CvxCompress")
run(`git checkout tqff/d20861c`)
cd(BUILD_HOME)

#
# build
#
run(`cp -r $(BUILD_HOME)/downloads/CvxCompress $(BUILD_HOME)/src/`)
cd("$(BUILD_HOME)/src/CvxCompress")
run(`make -f makefile.gcc libcvxcompress.so`)
run(`mkdir -p $(BUILD_HOME)/usr/lib`)
run(`cp libcvxcompress.so $(BUILD_HOME)/usr/lib/`)
cd(BUILD_HOME)
