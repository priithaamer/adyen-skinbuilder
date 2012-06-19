require 'spec_helper'

describe Adyen::SkinBuilder::Helper::Render do

  before do
    extend Adyen::SkinBuilder::Helper::Render
  end

  describe "#inject_underscore" do
    it { inject_underscore("file").should == "_file.html" }
    it { inject_underscore("path1/file").should == "path1/_file.html" }
    it { inject_underscore("/path1/file").should == "/path1/_file.html" }
    it { inject_underscore("/path1/path2/file").should == "/path1/path2/_file.html" }
  end
end
