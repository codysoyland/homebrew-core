class PilosaWebui < Formula
  desc "Web-based user interface for Pilosa"
  homepage "https://www.pilosa.com"
  url "https://github.com/pilosa/webui/archive/v0.1.tar.gz"
  sha256 "15f2b3b6d0fec2d51068cfcbf68452876f762476f0850a29933468963f67a31c"

  depends_on "dep" => :build
  depends_on "go" => :build
  depends_on "go-statik" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/pilosa/webui").install buildpath.children

    cd "src/github.com/pilosa/webui" do
      system "make", "build", "FLAGS=-o #{bin}/pilosa-webui", "VERSION=v#{version}"
      prefix.install_metafiles
    end
  end

  test do
    begin
      server = fork do
        exec "#{bin}/pilosa-webui"
      end
      sleep 0.5
      assert_match("<!DOCTYPE html>", shell_output("curl localhost:8000"))
    ensure
      Process.kill "TERM", server
      Process.wait server
    end
  end
end
