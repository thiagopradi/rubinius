require File.expand_path('../../../spec_helper', __FILE__)

describe "Process.setsid" do
  platform_is_not :windows do
    it "takes no arguments" do
      lambda { Process.setsid(0) }.should raise_error(ArgumentError)
    end
  end

  with_feature :fork do
    it "establishes this process as a new session and process group leader" do
      read, write = IO.pipe
      pid = Process.fork {
        begin
          read.close
          pgid = Process.setsid
          write << pgid.class.to_s
          write.close
        rescue Exception => e
          write << e << e.backtrace
        end
        Process.exit!
      }
      write.close
      klass = read.gets
      read.close
      klass.should == "Fixnum"
    end
  end
end
