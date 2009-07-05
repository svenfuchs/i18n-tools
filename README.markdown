I18n Tools
==========

Tools useful for working with Ruby/Rails I18n. Currently contains only the 
source parser tool.

I18n Keys Source Parser
-----------------------

(You can always have a look at thor -T for the current list of available Thor 
commands.)

**Requirements**

You need to use Ruby 1.9 because we depend on Ripper2Ruby which requires Ripper.
If you happen to know a way to compile/use Ripper for Ruby 1.8.x please let me
know.

Also, the library currently expects to find the gems I18n and Ripper2Ruby 
frozen to vendor/.

You also need Thor to use the command line tool. You might experience problems 
getting Thor to behave under Ruby 1.9. Please let me know when I can remove 
this notice ;)

**Installation**

	install i18n-tools (should require and install ripper2ruby)
	install thor
	thor install http://github.com/svenfuchs/i18n-tools/raw/master/i18n-tools.thor --as i18n-tools

**Usage**

	thor i18n:keys:find KEYS [--index] [--dir=DIR] [--pattern=PATTERN] [--context=N] 
	thor i18n:keys:find SEARCH REPLACE [--index] [--dir=DIR] [--pattern=PATTERN] [--context=N] [--verbose]

**Key Pattern**	

	foo   - finds all calls to I18n.t with the key 'foo'
	foo*  - finds all calls to I18n.t with keys starting with 'foo'
	*foo  - finds all calls to I18n.t with keys ending with 'foo'
	*foo* - finds all calls to I18n.t with keys containing 'foo'
	
	In most situations it might make sense to also use a dot, as in:
	foo.*, *.foo, *.foo.*

**Options**

	--index
		Build and/or use an index. When you use --index for the first time
		an index will be built. On subsequent usages the existing index will
		be used (largely speeding up the command).
		
	--dir
		Root directory where files matching the pattern are searched for. If you
		use a saved index this is also the directory where a .i18n/ directory
		will be created for the index file.
		
	--pattern
		Glob pattern that is used to find
		
	--context
		Output the given number of lines of context before and after occurences.

	--verbose
		Output additional information (e.g. while index being built). (Currently
		not supported)
	
**Examples**

	thor i18n:keys:find foo.* --index --dir=path/to/project --pattern=**/*.{rb,erb} --context=2
	thor i18n:keys:find foo.* bar --index --dir=path/to/project --pattern=**/*.{rb,erb} --context=2
	
	
**Notes**

If you're using zsh arguments given with a wildcard are expanded to filenames
before being passed. So <code>i18n-keys find foo.\*</code> won't work. You can
either use quotes as in <code>i18n-keys find "foo.\*"</code> or turn zsh
filename generation off with: <code>unsetopt GLOB</code>.

If you have Ruby 1.9 installed in parallel to 1.8.x you might want to install
Thor with the -E option to make the executable wrapper use /usr/bin/env
instead of hardcoding the path to your Ruby executable. E.g.: 

	sudo gem install wycats-thor -E --source=http://gems.github.com