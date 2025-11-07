# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://docs.brew.sh/rubydoc/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cangjie < Formula

  desc "cangjie ecosystem"
  homepage "https://cangjie-lang.cn/en"
  url "https://gitcode.com/Cangjie/cangjie_build/",
      using: :git,
      tag: "v1.0.5"
  license "Apache-2.0" => { with: "Runtime Library Exception" }

  depends_on "python@3.14" => :build
  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "llvm@16" => :build
  depends_on "openssl@3"
  depends_on "m4"
  depends_on "bison"
  depends_on "googletest"
  depends_on "gnu-tar"

  resource "cangjie_compiler" do
    url "https://gitcode.com/Cangjie/cangjie_compiler.git",
      using: :git,
      tag: "v1.0.5"
  end

  # Additional dependency
  resource "cangjie_runtime" do
    url "https://gitcode.com/Cangjie/cangjie_runtime.git",
      using: :git,
      tag: "v1.0.5"
  end
  resource "cangjie_tools" do
    url "https://gitcode.com/Cangjie/cangjie_tools.git",
      using: :git,
      tag: "v1.0.5"
  end
  resource "cangjie_stdx" do
    url "https://gitcode.com/Cangjie/cangjie_stdx.git",
      using: :git,
      tag: "v1.0.5.1"
  end

  def install
    arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
    sdk_name="mac-#{ENV["ARCH_NAME"]}"
    cangjie_version="1.5.0"
    stdx_version="1.5.0.1"
    ENV["ARCH"] = arch
    ENV["SDK_NAME"] = sdk_name
    ENV["CANGJIE_VERSION"] = cangjie_version
    ENV["STDX_VERSION"] = stdx_version

    ENV.prepend_path "PATH", Formula["llvm@16"].opt_bin
    ENV["CC"] = Formula["llvm@16"].opt_bin/"clang"
    ENV["CXX"] = Formula["llvm@16"].opt_bin/"clang++"
    ENV.prepend_path "PATH", Formula["m4"].opt_bin
    openssl_path=Formula["openssl@3"].opt_lib
    ENV["OPENSSL_PATH"] = openssl_path
    ENV.prepend_path "LD_LIBRARY_PATH", Formula["openssl@3"].opt_lib

    workspace=Dir.pwd
    resource("cangjie_compiler").stage buildpath/"cangjie_compiler"
    resource("cangjie_runtime").stage buildpath/"cangjie_runtime"
    resource("cangjie_tools").stage buildpath/"cangjie_tools"
    resource("cangjie_stdx").stage buildpath/"cangjie_stdx "

    # --- compiler ---
    Dir.chdir("#{workspace}/cangjie_compiler")

    # apply patch -- this should be temporary
    system "git", "remote", "add", "compiler_fix", "https://gitcode.com/claudio_/cangjie_compiler.git"
    system "git", "fetch", "compiler_fix"
    system "git", "cherry-pick", "092bef1a02f066ff2786d12f04a16063b30cca3d"

    system "python3", "build.py", "clean"
    system "python3", "build.py", "build", "-t", "release", "--no-tests", "--build-cjdb"
    system "python3", "build.py", "install"

    # --- runtime ---
    Dir.chdir("#{workspace}/cangjie_runtime/runtime")

    # apply patch -- this should be temporary
    system "git", "remote", "add", "runtime_fix", "https://gitcode.com/magnusmorton/cangjie_runtime.git"
    system "git", "fetch", "runtime_fix"
    system "git", "cherry-pick", "6fdd41f22576345e45c4c7b507d55593d556ed81"

    system "python3", "build.py", "clean"
    system "python3", "build.py", "build", "-t", "release", "-v", "#{cangjie_version}"
    system "python3", "build.py", "install"
    cp_r "#{workspace}/cangjie_runtime/runtime/output/common/darwin_release_#{arch}/lib" "#{workspace}/cangjie_compiler/output"
    cp_r "#{workspace}/cangjie_runtime/runtime/output/common/darwin_release_#{arch}/runtime" "#{workspace}/cangjie_compiler/output"

    # --- std ---
    Dir.chdir("#{workspace}/cangjie_runtime/stdlib")
    system "python3",  "build.py", "clean"
    system "python3",  "build.py", "build", "-t", "release", "--target-lib=#{workspace}/cangjie_runtime/runtime/output", "--target-lib=#{openssl_path}"
    system "python3",  "build.py", "install"
    cp_r "#{workspace}/cangjie_runtime/std/output/*" "#{workspace}/cangjie_compiler/output/"

    # --- stdx ---
    Dir.chdir("#{workspace}/cangjie_stdx")
    system "python3", "build.py", "clean"
    system "python3", "build.py", "build", "-t", "release", "--include=#{workspace}/cangjie_compiler/include", "--target-lib=#{openssl_path}"
    system "python3", "build.py", "install"
    # TODO: can we set this in the system?
    ENV["CANGJIE_STDX_PATH"]="#{workspace}/cangjie_stdx/target/darwin_${ARCH}_cjnative/static/stdx"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test cangjie`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
