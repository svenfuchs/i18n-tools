I18n Tools
==========

README is currently out of date. 

Tools useful for working with Ruby/Rails I18n. Currently contains only the 
source parser tool.

I18n Keys Source Parser
-----------------------

(You can always have a look at thor -T for the current list of available Thor 
commands.)

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
		
	--context
		Output the given number of lines of context before and after occurences.

	--verbose
		Output additional information (e.g. while index being built).
	
**Examples**

	thor i18n:keys:find foo.* --index --dir=path/to/project --pattern=**/*.{rb,erb} --context=2
	
	
If you're using zsh arguments given with a wildcard are expanded to filenames
before being passed. So <code>i18n-keys find foo.\*</code> won't work. You can
either use quotes as in <code>i18n-keys find "foo.\*"</code> or turn zsh
filename generation off with: <code>unsetopt GLOB</code>.

Notes
_____

If you have Ruby 1.9 installed in parallel to 1.8.x you might want to install
Thor with the -E option to make the executable wrapper use /usr/bin/env
instead of hardcoding the path to your Ruby executable. E.g.: 

	sudo gem install wycats-thor -E --source=http://gems.github.com