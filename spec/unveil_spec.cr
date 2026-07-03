# Copyright (c) 2021 joshua stein <jcs@jcs.org>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require "./spec_helper"

describe "unveil" do
  it "read a few files without unveil" do
    File.open("/etc/motd").class.should eq File
    File.open("/etc/passwd").class.should eq File
  end

  it "unveil a first path and see what happens" do
    Process.unveil({ "/etc/motd" => "r" })
    # /etc/motd is still readable, but no other path is.
    File.open("/etc/motd").class.should eq File
    begin
      File.open("/etc/passwd").class.should eq nil
    rescue e
      e.class.should eq File::NotFoundError
    end
  end

  it "prevent further unveiling after final unveil" do
    Process.unveil
    begin
      Process.unveil({ "/etc/passwd" => "r" })
    rescue e
      e.class.should eq Process::UnveilError
    end
  end
end
