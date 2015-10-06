require_relative 'spec_helper'

describe MT940Structured::Parsers::RegexSupport do
  let(:regex) { MT940Structured::Parsers::RegexSupport.regexify_keyword('FOO') }
  it 'creates a regex' do
    expect('/FOO/').to match regex
  end

  it 'adds slashes before the keyword' do
    expect('FOO/').to_not match regex
  end

  it 'adds slashes after the keyword' do
    expect('/FOO').to_not match regex
  end

  it 'ignores spaces around the keyword' do
    expect('/ FOO /').to match regex
  end

  it 'ignores spaces within the keyword' do
    expect('/F O O/').to match regex
  end

  it 'takes case into account' do
    expect('/foO/').to_not match regex
  end
end
