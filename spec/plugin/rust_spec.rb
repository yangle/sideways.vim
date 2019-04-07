require 'spec_helper'

describe "rust" do
  let(:filename) { 'test.rs' }

  describe "single-line lambdas as function call arguments" do
    before :each do
      set_file_contents <<-EOF
        function_call(|x| x.to_string(), y)
      EOF

      vim.set 'filetype', 'rust'
      vim.search('|x|')
    end

    specify "to the left" do
      vim.left

      assert_file_contents <<-EOF
        function_call(y, |x| x.to_string())
      EOF
    end

    specify "to the right" do
      vim.right

      assert_file_contents <<-EOF
        function_call(y, |x| x.to_string())
      EOF
    end
  end

  describe "multiline lambdas as function call arguments" do
    before :each do
      set_file_contents <<-EOF
        function_call(|x, z| {
          x.to_string()
        }, y)
      EOF

      vim.set 'filetype', 'rust'
      vim.search('|x')
    end

    specify "to the left" do
      vim.left

      assert_file_contents <<-EOF
        function_call(y, |x, z| {
          x.to_string()
        })
      EOF
    end

    specify "to the right" do
      vim.right

      assert_file_contents <<-EOF
        function_call(y, |x, z| {
          x.to_string()
        })
      EOF
    end
  end

  describe "lambda params" do
    before :each do
      set_file_contents <<-EOF
        iterator.map(|_, mut v: Vec<_>| {
            v.sort_unstable();
            v
        })
      EOF

      vim.set 'filetype', 'rust'
      vim.search('_,')
    end

    specify "to the left" do
      vim.left

      assert_file_contents <<-EOF
        iterator.map(|mut v: Vec<_>, _| {
            v.sort_unstable();
            v
        })
      EOF
    end

    specify "to the right" do
      vim.right

      assert_file_contents <<-EOF
        iterator.map(|mut v: Vec<_>, _| {
            v.sort_unstable();
            v
        })
      EOF
    end
  end

  describe "template args in types" do
    before :each do
      set_file_contents <<-EOF
        let dict = HashSet<String, Vec<String>>::new();
      EOF

      vim.set 'filetype', 'rust'
      vim.search('String,')
    end

    specify "to the left" do
      vim.left
      assert_file_contents <<-EOF
        let dict = HashSet<Vec<String>, String>::new();
      EOF
    end

    specify "to the right" do
      vim.right
      assert_file_contents <<-EOF
        let dict = HashSet<Vec<String>, String>::new();
      EOF
    end
  end

  describe "template args in struct definitions" do
    before :each do
      set_file_contents <<-EOF
        pub struct Forth {
            stack: Vec<Value>,
            environment: HashMap<String, String>,
        }
      EOF

      vim.set 'filetype', 'rust'
      vim.search('stack:')
    end

    specify "to the left" do
      vim.left
      assert_file_contents <<-EOF
        pub struct Forth {
            environment: HashMap<String, String>,
            stack: Vec<Value>,
        }
      EOF
    end
  end

  describe "template args in tuple struct definitions" do
    before :each do
      set_file_contents <<-EOF
        pub struct Forth(Vec<Value>, HashMap<String, String>)
      EOF

      vim.set 'filetype', 'rust'
      vim.search('Vec')
    end

    specify "to the left" do
      vim.left
      assert_file_contents <<-EOF
        pub struct Forth(HashMap<String, String>, Vec<Value>)
      EOF
    end
  end

  describe "template args in a newtype declaration" do
    before :each do
      set_file_contents <<-EOF
        type Foo = (First<Foo, Bar>, Second<Foo, Bar>)
      EOF

      vim.set 'filetype', 'rust'
      vim.search('First')
    end

    specify "to the left" do
      vim.left
      assert_file_contents <<-EOF
        type Foo = (Second<Foo, Bar>, First<Foo, Bar>)
      EOF
    end
  end

  describe "template args in a turbofish" do
    before :each do
      set_file_contents <<-EOF
        let list = iterator.collect::<Vec<String>, ()>();
      EOF

      vim.set 'filetype', 'rust'
      vim.search('Vec')
    end

    specify "to the left" do
      vim.left
      assert_file_contents <<-EOF
        let list = iterator.collect::<(), Vec<String>>();
      EOF
    end

    specify "to the right" do
      vim.right
      assert_file_contents <<-EOF
        let list = iterator.collect::<(), Vec<String>>();
      EOF
    end
  end

  describe "correct cursor position in nested template args" do
    before :each do
      set_file_contents <<-EOF
        Result<Box<Error>, ()>
      EOF

      vim.set 'filetype', 'rust'
      vim.search('Box')
    end

    specify "to the left" do
      vim.left
      expect(vim.echo('expand("<cword>")')).to eq 'Box'

      vim.left
      expect(vim.echo('expand("<cword>")')).to eq 'Box'
    end

    specify "to the right" do
      vim.right
      expect(vim.echo('expand("<cword>")')).to eq 'Box'

      vim.right
      expect(vim.echo('expand("<cword>")')).to eq 'Box'
    end
  end

  describe "lifetimes in a function declaration" do
    before :each do
      set_file_contents <<-EOF
        fn define_custom<'a, 'b>(&mut self, mut i: S<'a>) -> Result<S<'a>, Error> { }
      EOF

      vim.set 'filetype', 'rust'
      vim.search('mut i')
    end

    specify "to the left" do
      vim.left
      assert_file_contents <<-EOF
        fn define_custom<'a, 'b>(mut i: S<'a>, &mut self) -> Result<S<'a>, Error> { }
      EOF
    end
  end

  describe "comparison in a function invocation" do
    before :each do
      set_file_contents <<-EOF
        foo(a < b, b > c);
      EOF

      vim.set 'filetype', 'rust'
      vim.search('a < b')
    end

    specify "to the right" do
      vim.left
      assert_file_contents <<-EOF
        foo(b > c, a < b);
      EOF
    end
  end

  describe "text object for a result" do
    before :each do
      set_file_contents <<-EOF
        fn example() -> Result<String, String> {
        }
      EOF

      vim.set 'filetype', 'rust'
      vim.search('Result')
    end

    specify "change result type" do
      vim.feedkeys 'ciaOption<String>'
      vim.write
      assert_file_contents <<-EOF
        fn example() -> Option<String> {
        }
      EOF
    end
  end
end
