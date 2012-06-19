require 'spec_helper'

describe Adyen::SkinBuilder::Helper::Render do

  before do
    extend Adyen::SkinBuilder::Helper::Render
  end

  describe "#partialize" do
    it { partialize("file").should == "_file.html.erb" }
    it { partialize("path1/file").should == "path1/_file.html.erb" }
    it { partialize("/path1/file").should == "/path1/_file.html.erb" }
    it { partialize("/path1/path2/file").should == "/path1/path2/_file.html.erb" }
  end
end
