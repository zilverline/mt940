require_relative 'spec_helper'

describe "Base" do

  context 'MT940::Base' do
    it 'read the transactions with the filename of the MT940 file' do
      file_name = File.dirname(__FILE__) + '/fixtures/ing.txt'
      @transactions = MT940::Base.parse_mt940(file_name)["1234567"].flat_map(&:transactions)
      @transactions.size.should == 6
    end

    it 'read the transactions with the handle to the mt940 file itself' do
      file_name = File.dirname(__FILE__) + '/fixtures/ing.txt'
      file = File.open(file_name)
      @transactions = MT940::Base.parse_mt940(file)["1234567"].flat_map(&:transactions)
      @transactions.size.should == 6
    end

    #Tempfile is used by Paperclip, so the following will work:
    #MT940::Base.transactions(@mt940_file.attachment.to_file)
    it 'read the transactions with the handle of a Tempfile' do
      file = Tempfile.new('temp')
      file.write(':940:')
      file.rewind
      @transactions = MT940::Base.parse_mt940(file)
      @transactions.size.should == 0
      file.unlink
    end

    it 'raise an exception if the file does not exist' do
      file_name = File.dirname(__FILE__) + '/fixtures/123.txt'
      expect {MT940::Base.parse_mt940(file_name)}.to raise_exception Errno::ENOENT
    end

    it 'raise an ArgumentError if a wrong argument was given' do
      expect {MT940::Base.parse_mt940(Hash.new)}.to raise_exception ArgumentError
    end
  end

  context 'Unknown MT940 file' do
    it 'return its bank' do
      file_name = File.dirname(__FILE__) + '/fixtures/unknown.txt'
      @transactions = MT940::Base.parse_mt940(file_name)["1234567"].flat_map(&:transactions)
      @transactions.first.bank.should == 'Unknown'
    end
  end

end
