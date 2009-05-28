I18n Tools
==========

Tools useful for working with Ruby/Rails I18n. Currently contains only the 
source parser tool.

I18n Keys Source Parser
-----------------------

**Usage**

	i18n-keys [cmd] [key_pattern] [options]
	i18n-keys find foo.bar.* --index  --verbose
	
**Key Pattern**	

	foo   - finds all occurences of the key 'foo'
	foo*  - finds all occurences of keys starting with 'foo'
	*foo  - finds all occurences of keys ending with 'foo'
	*foo* - finds all occurences of keys containing 'foo'
	
	In most situations it might make sense to also use a dot, as in:
	foo.*, *.foo, *.foo.*

**Options**

	--index
		Build and/or use an index. When you use --index for the first time
		an index will be built. On subsequent usages the existing index will
		be used (largely speeding up the command).

	--verbose
		Output additional information (e.g. while index being built).
	
If you're using zsh arguments given with a wildcard are expanded to filenames
before being passed. So <code>i18n-keys find foo.\*</code> won't work. You can
either use quotes as in <code>i18n-keys find "foo.\*"</code> or turn zsh
filename generation off with: <code>unsetopt GLOB</code>.