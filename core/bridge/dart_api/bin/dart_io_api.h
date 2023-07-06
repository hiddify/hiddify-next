// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef RUNTIME_INCLUDE_BIN_DART_IO_API_H_
#define RUNTIME_INCLUDE_BIN_DART_IO_API_H_

#include "dart_tools_api.h"

namespace dart {
namespace bin {

// Bootstraps 'dart:io'.
void BootstrapDartIo();

// Cleans up 'dart:io'.
void CleanupDartIo();

// Lets dart:io know where the system temporary directory is located.
// Currently only wired up on Android.
void SetSystemTempDirectory(const char* system_temp);

// Tells the system whether to capture Stdout events.
void SetCaptureStdout(bool value);

// Tells the system whether to capture Stderr events.
void SetCaptureStderr(bool value);

// Should Stdout events be captured?
bool ShouldCaptureStdout();

// Should Stderr events be captured?
bool ShouldCaptureStderr();

// Set the executable name used by Platform.executable.
void SetExecutableName(const char* executable_name);

// Set the arguments used by Platform.executableArguments.
void SetExecutableArguments(int script_index, char** argv);

// Set dart:io implementation specific fields of Dart_EmbedderInformation.
void GetIOEmbedderInformation(Dart_EmbedderInformation* info);

// Appropriate to assign to Dart_InitializeParams.file_open/read/write/close.
void* OpenFile(const char* name, bool write);
void ReadFile(uint8_t** data, intptr_t* file_len, void* stream);
void WriteFile(const void* buffer, intptr_t num_bytes, void* stream);
void CloseFile(void* stream);

// Generates 'length' random bytes into 'buffer'. Returns true on success
// and false on failure. This is appropriate to assign to
// Dart_InitializeParams.entropy_source.
bool GetEntropy(uint8_t* buffer, intptr_t length);

// Performs a lookup of the I/O Dart_NativeFunction with a specified 'name' and
// 'argument_count'. Returns NULL if no I/O native function with a matching
// name and parameter count is found.
Dart_NativeFunction LookupIONative(Dart_Handle name,
                                   int argument_count,
                                   bool* auto_setup_scope);

// Returns the symbol for I/O native function 'nf'. Returns NULL if 'nf' is not
// a valid I/O native function.
const uint8_t* LookupIONativeSymbol(Dart_NativeFunction nf);

}  // namespace bin
}  // namespace dart

#endif  // RUNTIME_INCLUDE_BIN_DART_IO_API_H_
