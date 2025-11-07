# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://docs.brew.sh/rubydoc/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cangjie < Formula

  desc "cangjie ecosystem"
  homepage "https://cangjie-lang.cn/en"
  url "https://gitcode.com/Cangjie/cangjie_compiler.git",
    using: :git,
    tag: "v1.0.5"
  license "Apache-2.0" => { with: "Runtime Library Exception" }

  depends_on "python@3.14"
  depends_on "ninja"
  depends_on "llvm@16"
  depends_on "openssl@3"
  depends_on "m4"
  depends_on "bison"
  depends_on "googletest"
  depends_on "gnu-tar"

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
    ENV["ARCH_NAME"] = arch
    ENV["SDK_NAME"] = "mac-#{ENV["ARCH_NAME"]}"
    ENV["CANGJIE_VERSION"] = "1.0.0"
    ENV["STDX_VERSION"] = "1"

    ENV.append_path "PATH", Formula["llvm@16"].lib
    ENV.append_path "PATH", Formula["m4"].lib
    ENV["OPENSSL_PATH"] = Formula["openssl@3"].lib
    ENV.append_path "LD_LIBRARY_PATH", Formula["openssl@3"].lib

    system "echo", "#{ENV["ARCH_NAME"]}"
    system "echo", "#{ENV["SDK_NAME"]}"
    system "echo", "#{ENV["CANGJIE_VERSION"]}"
    system "echo", "#{ENV["PATH"]}"
    system "echo", "#{ENV["OPENSSL_PATH"]}"
    system "echo", "#{ENV["LD_LIBRARY_PATH"]}"
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
