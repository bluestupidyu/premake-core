--
-- tests/test_nvcc.lua
-- Automated test suite for the NVCC toolset interface.
-- Copyright (c) 2009-2016 the Premake project
--

	local suite = test.declare("tools_nvcc")

	local nvcc = premake.tools.nvcc
	local project = premake.project


--
-- Setup/teardown
--

	local wks, prj, cfg

	function suite.setup()
		wks, prj = test.createWorkspace()
		system "Linux"
	end

	local function prepare()
		cfg = test.getconfig(prj, "Debug")
	end


--
-- Check the selection of tools based on the target system.
--

	function suite.tools_onDefaults()
		prepare()
		test.isequal("nvcc", nvcc.gettoolname(cfg, "cc"))
		test.isequal("nvcc", nvcc.gettoolname(cfg, "cxx"))
		test.isnil(nvcc.gettoolname(cfg, "ar"))
	end

--
-- Check the translation of CFLAGS.
--

	function suite.cflags_onExtraWarnings()
		warnings "extra"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -Wall", "-Xcompiler -Wextra" }, cflags)
		test.excludes({ "-Wall", "-Wextra" }, cflags)
	end

	function suite.cflags_onFatalWarnings()
		flags { "FatalWarnings" }
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -Werror" }, cflags)
		test.excludes({ "-Werror" }, cflags)
	end

	function suite.cflags_onSpecificWarnings()
		enablewarnings { "enable" }
		disablewarnings { "disable" }
		fatalwarnings { "fatal" }
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -Wenable", "-Xcompiler -Wno-disable", "-Werror=fatal" }, cflags)
        test.excludes({ "-Wenable", "-Wno-disable", "-Werror=fatal" })
	end

	function suite.cflags_onFloastFast()
		floatingpoint "Fast"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -ffast-math" }, cflags)
		test.excludes({ "-ffast-math" }, cflags)
	end

	function suite.cflags_onFloastStrict()
		floatingpoint "Strict"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -ffloat-store" }, cflags)
		test.excludes({ "-ffloat-store" }, cflags)
	end

	function suite.cflags_onNoWarnings()
		warnings "Off"
		prepare()
		test.contains({ "-w" }, nvcc.getcflags(cfg))
	end

	function suite.cflags_onSSE()
		vectorextensions "SSE"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -msse" }, cflags)
		test.excludes({ "-msse" }, cflags)
	end

	function suite.cflags_onSSE2()
		vectorextensions "SSE2"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -msse2" }, cflags)
		test.excludes({ "-msse2" }, cflags)
	end

	function suite.cflags_onAVX()
		vectorextensions "AVX"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -mavx" }, cflags)
		test.excludes({ "-mavx" }, cflags)
	end

	function suite.cflags_onAVX2()
		vectorextensions "AVX2"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -mavx2" }, cflags)
		test.excludes({ "-mavx2" }, cflags)
	end


--
-- Check the defines and undefines.
--

	function suite.defines()
		defines "DEF"
		prepare()
		test.contains({ "-DDEF" }, nvcc.getdefines(cfg.defines))
	end

	function suite.undefines()
		undefines "UNDEF"
		prepare()
		test.contains({ "-UUNDEF" }, nvcc.getundefines(cfg.undefines))
	end


--
-- Check the optimization flags.
--

	function suite.cflags_onNoOptimize()
		optimize "Off"
		prepare()
		test.contains({ "-O0" }, nvcc.getcflags(cfg))
	end

	function suite.cflags_onOptimize()
		optimize "On"
		prepare()
		test.contains({ "-O2" }, nvcc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeSize()
		optimize "Size"
		prepare()
		test.contains({ "-Os" }, nvcc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeSpeed()
		optimize "Speed"
		prepare()
		test.contains({ "-O3" }, nvcc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeFull()
		optimize "Full"
		prepare()
		test.contains({ "-O3" }, nvcc.getcflags(cfg))
	end

	function suite.cflags_onOptimizeDebug()
		optimize "Debug"
		prepare()
		test.contains({ "-O0" }, nvcc.getcflags(cfg))
	end


--
-- Check the translation of symbols.
--

	function suite.cflags_onDefaultSymbols()
		prepare()
		test.excludes({ "-g" }, nvcc.getcflags(cfg))
	end

	function suite.cflags_onNoSymbols()
		symbols "Off"
		prepare()
		test.excludes({ "-g" }, nvcc.getcflags(cfg))
	end

	function suite.cflags_onSymbols()
		symbols "On"
		prepare()
		test.contains({ "-g" }, nvcc.getcflags(cfg))
	end


--
-- Check the translation of CXXFLAGS.
--

	function suite.cflags_onNoExceptions()
		exceptionhandling "Off"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -fno-exceptions" }, cflags)
		test.excludes({ "-fno-exceptions" }, cflags)
	end

	function suite.cflags_onNoBufferSecurityCheck()
		flags { "NoBufferSecurityCheck" }
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -fno-stack-protector" }, cflags)
		test.excludes({ "-fno-stack-protector" }, cflags)
	end


--
-- Check the basic translation of LDFLAGS for a Posix system.
--

	function suite.ldflags_onNoSymbols()
		prepare()
		test.excludes({ "-s", "-Xlinker -s" }, nvcc.getldflags(cfg))
	end

	function suite.ldflags_onSymbols()
		symbols "On"
		prepare()
        ldflags = nvcc.getldflags(cfg)
		test.contains({ "-Xlinker -s" }, ldflags)
		test.excludes({ "-s" }, ldflags)
	end

	function suite.ldflags_onSharedLib()
		kind "SharedLib"
		prepare()
		test.contains({ "-shared" }, nvcc.getldflags(cfg))
	end


--
-- Check Mac OS X variants on LDFLAGS.
--

	function suite.ldflags_onMacOSXNoSymbols()
		system "MacOSX"
		prepare()
        ldflags = nvcc.getldflags(cfg)
		test.contains({ "-Xlinker -Wl,-x" }, ldflags)
		test.excludes({ "-Wl,-x" }, ldflags)
	end

	function suite.ldflags_onMacOSXSharedLib()
		system "MacOSX"
		kind "SharedLib"
		prepare()
        ldflags = nvcc.getldflags(cfg)
		test.contains({ "-Xlinker -dynamiclib" }, ldflags)
		test.excludes({ "-dynamiclib" }, ldflags)
	end


--
-- Check Windows variants on LDFLAGS.
--

	function suite.ldflags_onWindowsharedLib()
		system "Windows"
		kind "SharedLib"
		prepare()
        ldflags = nvcc.getldflags(cfg)
		test.contains({ "-Xlinker -shared", '-Xlinker -Wl,--out-implib="bin/Debug/MyProject.lib"' }, ldflags)
		test.excludes({ "-shared", '-Wl,--out-implib="bin/Debug/MyProject.lib"' }, ldflags)
	end

	function suite.ldflags_onWindowsApp()
		system "Windows"
		kind "WindowedApp"
		prepare()
        ldflags = nvcc.getldflags(cfg)
		test.contains({ "-Xlinker -mwindows" }, ldflags)
		test.excludes({ "-mwindows" }, ldflags)
	end



--
-- Make sure system or architecture flags are added properly.
--

	function suite.cflags_onX86()
		architecture "x86"
		prepare()
		test.contains({ "-m32" }, nvcc.getcflags(cfg))
	end

	function suite.ldflags_onX86()
		architecture "x86"
		prepare()
		test.contains({ "-m32" }, nvcc.getldflags(cfg))
	end

	function suite.cflags_onX86_64()
		architecture "x86_64"
		prepare()
		test.contains({ "-m64" }, nvcc.getcflags(cfg))
	end

	function suite.ldflags_onX86_64()
		architecture "x86_64"
		prepare()
		test.contains({ "-m64" }, nvcc.getldflags(cfg))
	end


--
-- Non-Windows shared libraries should marked as position independent.
--

	function suite.cflags_onWindowsSharedLib()
		system "MacOSX"
		kind "SharedLib"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xlinker -fPIC" }, cflags)
		test.excludes({ "-fPIC" }, cflags)
	end


--
-- Check the formatting of linked system libraries.
--

	function suite.links_onSystemLibs()
		links { "fs_stub", "net_stub" }
		prepare()
		test.contains({ "-lfs_stub", "-lnet_stub" }, nvcc.getlinks(cfg))
	end

	function suite.links_onSystemLibs_onWindows()
		system "windows"
		links { "ole32" }
		prepare()
		test.contains({ "-lole32" }, nvcc.getlinks(cfg))
	end


--
-- When linking to a static sibling library, the relative path to the library
-- should be used instead of the "-l" flag. This prevents linking against a
-- shared library of the same name, should one be present.
--

	function suite.links_onStaticSiblingLibrary()
		links { "MyProject2" }

		test.createproject(wks)
		system "Linux"
		kind "StaticLib"
		targetdir "lib"

		prepare()
		test.isequal({ "lib/libMyProject2.a" }, nvcc.getlinks(cfg))
	end


--
-- Use the -lname format when linking to sibling shared libraries.
--

	function suite.links_onSharedSiblingLibrary()
		links { "MyProject2" }

		test.createproject(wks)
		system "Linux"
		kind "SharedLib"
		targetdir "lib"

		prepare()
		test.isequal({ "lib/libMyProject2.so" }, nvcc.getlinks(cfg))
	end


--
-- When linking object files, leave off the "-l".
--

	function suite.links_onObjectFile()
		links { "generated.o" }
		prepare()
		test.isequal({ "generated.o" }, nvcc.getlinks(cfg))
	end


--
-- If the object file is referenced with a path, it should be
-- made relative to the project.
--

	function suite.links_onObjectFileOutsideProject()
		location "MyProject"
		links { "obj/Debug/generated.o" }
		prepare()
		test.isequal({ "../obj/Debug/generated.o" }, nvcc.getlinks(cfg))
	end


--
-- Make sure shell variables are kept intact for object file paths.
--

	function suite.links_onObjectFileWithShellVar()
		location "MyProject"
		links { "$(IntDir)/generated.o" }
		prepare()
		test.isequal({ "$(IntDir)/generated.o" }, nvcc.getlinks(cfg))
	end


--
-- Include directories should be made project relative.
--

	function suite.includeDirsAreRelative()
		includedirs { "../include", "src/include" }
		prepare()
		test.isequal({ '-I../include', '-Isrc/include' }, nvcc.getincludedirs(cfg, cfg.includedirs))
	end


--
-- Check handling of forced includes.
--

	function suite.forcedIncludeFiles()
		forceincludes { "stdafx.h", "include/sys.h" }
		prepare()
		test.isequal({'-include stdafx.h', '-include include/sys.h'}, nvcc.getforceincludes(cfg))
	end


--
-- Include directories containing spaces (or which could contain spaces)
-- should be wrapped in quotes.
--

	function suite.includeDirs_onSpaces()
		includedirs { "include files" }
		prepare()
		test.isequal({ '-I"include files"' }, nvcc.getincludedirs(cfg, cfg.includedirs))
	end

	function suite.includeDirs_onEnvVars()
		includedirs { "$(IntDir)/includes" }
		prepare()
		test.isequal({ '-I"$(IntDir)/includes"' }, nvcc.getincludedirs(cfg, cfg.includedirs))
	end



--
-- Check handling of strict aliasing flags.
--

	function suite.cflags_onNoStrictAliasing()
		strictaliasing "Off"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains("-Xcompiler -fno-strict-aliasing", cflags)
		test.excludes("-fno-strict-aliasing", cflags)
	end

	function suite.cflags_onLevel1Aliasing()
		strictaliasing "Level1"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -fno-strict-aliasing", "-Xcompiler -Wstrict-aliasing=1" }, cflags)
		test.excludes({ "-fno-strict-aliasing", "-Wstrict-aliasing=1" }, cflags)
	end

	function suite.cflags_onLevel2Aliasing()
		strictaliasing "Level2"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -fno-strict-aliasing", "-Xcompiler -Wstrict-aliasing=2" }, cflags)
		test.excludes({ "-fno-strict-aliasing", "-Wstrict-aliasing=2" }, cflags)
	end

	function suite.cflags_onLevel3Aliasing()
		strictaliasing "Level3"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains({ "-Xcompiler -fno-strict-aliasing", "-Xcompiler -Wstrict-aliasing=3" }, cflags)
		test.excludes({ "-fno-strict-aliasing", "-Wstrict-aliasing=3" }, cflags)
	end


--
-- Check handling of system search paths.
--

	function suite.includeDirs_onSysIncludeDirs()
		sysincludedirs { "/usr/local/include" }
		prepare()
		test.contains("-isystem /usr/local/include", nvcc.getincludedirs(cfg, cfg.includedirs, cfg.sysincludedirs))
	end

	function suite.libDirs_onSysLibDirs()
		syslibdirs { "/usr/local/lib" }
		prepare()
		test.contains("-L/usr/local/lib", nvcc.getLibraryDirectories(cfg))
	end


--
-- Check handling of link time optimization flag.
--

	function suite.cflags_onLinkTimeOptimization()
		flags "LinkTimeOptimization"
		prepare()
        cflags = nvcc.getcflags(cfg)
		test.contains("-flto", cflags)
		test.excludes("-flto", cflags)
	end


--
-- Check link mode preference for system libraries.
--
	function suite.linksModePreference_onAllStatic()
		links { "fs_stub:static", "net_stub:static" }
		prepare()
		test.contains({ "-Wl,-Bstatic", "-lfs_stub", "-Wl,-Bdynamic", "-lnet_stub"}, nvcc.getlinks(cfg))
	end

	function suite.linksModePreference_onStaticAndShared()
		links { "fs_stub:static", "net_stub" }
		prepare()
		test.contains({ "-Wl,-Bstatic", "-lfs_stub", "-Wl,-Bdynamic", "-lnet_stub"}, nvcc.getlinks(cfg))
	end

	function suite.linksModePreference_onAllShared()
		links { "fs_stub:shared", "net_stub:shared" }
		prepare()
		test.excludes({ "-Wl,-Bstatic" }, nvcc.getlinks(cfg))
	end
