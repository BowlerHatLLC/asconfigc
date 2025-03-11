/*
Copyright 2016-2021 Bowler Hat LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package com.as3mxml.asconfigc
{
	public class CompilerOptions
	{
		public static const ACCESSIBLE:String = "accessible";
		public static const ADVANCED_TELEMETRY:String = "advanced-telemetry";
		public static const BENCHMARK:String = "benchmark";
		public static const CONTEXT_ROOT:String = "context-root";
		public static const CONTRIBUTOR:String = "contributor";
		public static const CREATOR:String = "creator";
		public static const DATE:String = "date";
		public static const DEBUG:String = "debug";
		public static const DEBUG_PASSWORD:String = "debug-password";
		public static const DEFAULT_BACKGROUND_COLOR:String = "default-background-color";
		public static const DEFAULT_FRAME_RATE:String = "default-frame-rate";
		public static const DEFAULT_SIZE:String = "default-size";
		public static const DEFAULT_SIZE__WIDTH:String = "width";
		public static const DEFAULT_SIZE__HEIGHT:String = "height";
		public static const DEFAULTS_CSS_FILES:String = "defaults-css-files";
		public static const DEFINE:String = "define";
		public static const DEFINE__NAME:String = "name";
		public static const DEFINE__VALUE:String = "value";
		public static const DESCRIPTION:String = "description";
		public static const DIRECTORY:String = "directory";
		public static const DUMP_CONFIG:String = "dump-config";
		public static const EXTERNAL_LIBRARY_PATH:String = "external-library-path";
		public static const INCLUDES:String = "includes";
		public static const INCLUDE_LIBRARIES:String = "include-libraries";
		public static const KEEP_ALL_TYPE_SELECTORS:String = "keep-all-type-selectors";
		public static const KEEP_AS3_METADATA:String = "keep-as3-metadata";
		public static const KEEP_GENERATED_ACTIONSCRIPT:String = "keep-generated-actionscript";
		public static const LANGUAGE:String = "language";
		public static const LIBRARY_PATH:String = "library-path";
		public static const LINK_REPORT:String = "link-report";
		public static const LOAD_CONFIG:String = "load-config";
		public static const LOAD_EXTERNS:String = "load-externs";
		public static const LOCALE:String = "locale";
		public static const NAMESPACE:String = "namespace";
		public static const NAMESPACE__URI:String = "uri";
		public static const NAMESPACE__MANIFEST:String = "manifest";
		public static const OPTIMIZE:String = "optimize";
		public static const OMIT_TRACE_STATEMENTS:String = "omit-trace-statements";
		public static const OUTPUT:String = "output";
		public static const PRELOADER:String = "preloader";
		public static const PUBLISHER:String = "publisher";
		public static const SERVICES:String = "services";
		public static const SHOW_UNUSED_TYPE_SELECTOR_WARNINGS:String = "show-unused-type-selector-warnings";
		public static const SIZE_REPORT:String = "size-report";
		public static const SOURCE_PATH:String = "source-path";
		public static const STATIC_LINK_RUNTIME_SHARED_LIBRARIES:String = "static-link-runtime-shared-libraries";
		public static const STRICT:String = "strict";
		public static const SWF_VERSION:String = "swf-version";
		public static const TARGET_PLAYER:String = "target-player";
		public static const THEME:String = "theme";
		public static const TITLE:String = "title";
		public static const TOOLS_LOCALE:String = "tools-locale";
		public static const USE_DIRECT_BLIT:String = "use-direct-blit";
		public static const USE_GPU:String = "use-gpu";
		public static const USE_NETWORK:String = "use-network";
		public static const USE_RESOURCE_BUNDLE_METADATA:String = "use-resource-bundle-metadata";
		public static const VERBOSE_STACKTRACES:String = "verbose-stacktraces";
		public static const WARNINGS:String = "warnings";

		//royale options
		public static const ALLOW_ABSTRACT_CLASSES:String = "allow-abstract-classes";
		public static const ALLOW_IMPORT_ALIASES:String = "allow-import-aliases";
		public static const ALLOW_PRIVATE_CONSTRUCTORS:String = "allow-private-constructors";
		public static const EXCLUDE_DEFAULTS_CSS_FILES:String = "exclude-defaults-css-files";
		public static const EXPORT_PUBLIC_SYMBOLS:String = "export-public-symbols";
		public static const EXPORT_PROTECTED_SYMBOLS:String = "export-protected-symbols";
		public static const EXPORT_INTERNAL_SYMBOLS:String = "export-internal-symbols";
		public static const HTML_OUTPUT_FILENAME:String = "html-output-filename";
		public static const HTML_TEMPLATE:String = "html-template";
		public static const INLINE_CONSTANTS:String = "inline-constants";
		public static const JS_COMPILER_OPTION:String = "js-compiler-option";
		public static const JS_COMPLEX_IMPLICIT_COERCIONS:String = "js-complex-implicit-coercions";
		public static const JS_DEFAULT_INITIALIZERS:String = "js-default-initializers";
		public static const JS_DYNAMIC_ACCESS_UNKNOWN_MEMBERS:String = "js-dynamic-access-unknown-members";
		public static const JS_DEFINE:String = "js-define";
		public static const JS_EXTERNAL_LIBRARY_PATH:String = "js-external-library-path";
		public static const JS_LIBRARY_PATH:String = "js-library-path";
		public static const JS_LOAD_CONFIG:String = "js-load-config";
		public static const JS_OUTPUT:String = "js-output";
		public static const JS_OUTPUT_OPTIMIZATION:String = "js-output-optimization";
		public static const JS_OUTPUT_TYPE:String = "js-output-type";
		public static const JS_VECTOR_EMULATION_CLASS:String = "js-vector-emulation-class";
		public static const JS_VECTOR_INDEX_CHECKS:String = "js-vector-index-checks";
		public static const PREVENT_RENAME_PUBLIC_SYMBOLS:String = "prevent-rename-public-symbols";
		public static const PREVENT_RENAME_PUBLIC_STATIC_METHODS:String = "prevent-rename-public-static-methods";
		public static const PREVENT_RENAME_PUBLIC_INSTANCE_METHODS:String = "prevent-rename-public-instance-methods";
		public static const PREVENT_RENAME_PUBLIC_STATIC_VARIABLES:String = "prevent-rename-public-static-variables";
		public static const PREVENT_RENAME_PUBLIC_INSTANCE_VARIABLES:String = "prevent-rename-public-instance-variables";
		public static const PREVENT_RENAME_PUBLIC_STATIC_ACCESSORS:String = "prevent-rename-public-static-accessors";
		public static const PREVENT_RENAME_PUBLIC_INSTANCE_ACCESSORS:String = "prevent-rename-public-instance-accessors";
		public static const PREVENT_RENAME_PROTECTED_SYMBOLS:String = "prevent-rename-protected-symbols";
		public static const PREVENT_RENAME_PROTECTED_STATIC_METHODS:String = "prevent-rename-protected-static-methods";
		public static const PREVENT_RENAME_PROTECTED_INSTANCE_METHODS:String = "prevent-rename-protected-instance-methods";
		public static const PREVENT_RENAME_PROTECTED_STATIC_VARIABLES:String = "prevent-rename-protected-static-variables";
		public static const PREVENT_RENAME_PROTECTED_INSTANCE_VARIABLES:String = "prevent-rename-protected-instance-variables";
		public static const PREVENT_RENAME_PROTECTED_STATIC_ACCESSORS:String = "prevent-rename-protected-static-accessors";
		public static const PREVENT_RENAME_PROTECTED_INSTANCE_ACCESSORS:String = "prevent-rename-protected-instance-accessors";
		public static const PREVENT_RENAME_INTERNAL_SYMBOLS:String = "prevent-rename-internal-symbols";
		public static const PREVENT_RENAME_INTERNAL_STATIC_METHODS:String = "prevent-rename-internal-static-methods";
		public static const PREVENT_RENAME_INTERNAL_INSTANCE_METHODS:String = "prevent-rename-internal-instance-methods";
		public static const PREVENT_RENAME_INTERNAL_STATIC_VARIABLES:String = "prevent-rename-internal-static-variables";
		public static const PREVENT_RENAME_INTERNAL_INSTANCE_VARIABLES:String = "prevent-rename-internal-instance-variables";
		public static const PREVENT_RENAME_INTERNAL_STATIC_ACCESSORS:String = "prevent-rename-internal-static-accessors";
		public static const PREVENT_RENAME_INTERNAL_INSTANCE_ACCESSORS:String = "prevent-rename-internal-instance-accessors";
		public static const REMOVE_CIRCULARS:String = "remove-circulars";
		public static const SOURCE_MAP:String = "source-map";
		public static const SOURCE_MAP_SOURCE_ROOT:String = "source-map-source-root";
		public static const STRICT_IDENTIFIER_NAMES:String = "strict-identifier-names";
		public static const SWF_EXTERNAL_LIBRARY_PATH:String = "swf-external-library-path";
		public static const SWF_LIBRARY_PATH:String = "swf-library-path";
		public static const TARGETS:String = "targets";
		public static const WARN_PUBLIC_VARS:String = "warn-public-vars";

		//library options
		public static const INCLUDE_CLASSES:String = "include-classes";
		public static const INCLUDE_FILE:String = "include-file";
		public static const INCLUDE_FILE__FILE:String = "file";
		public static const INCLUDE_FILE__PATH:String = "path";
		public static const INCLUDE_NAMESPACES:String = "include-namespaces";
		public static const INCLUDE_SOURCES:String = "include-sources";
	}
}