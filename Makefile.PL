use inc::Module::Install;
name 'Filter-Handle';
all_from 'lib/Filter/Handle.pm';
readme_from 'lib/Filter/Handle.pm';

test_requires 'Test::More';

use_test_base;
auto_include_deps;
author_tests('xt');
auto_set_repository;
WriteAll;