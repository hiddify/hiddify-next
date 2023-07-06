// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef RUNTIME_INCLUDE_DART_EMBEDDER_API_H_
#define RUNTIME_INCLUDE_DART_EMBEDDER_API_H_

#include "include/dart_api.h"
#include "include/dart_tools_api.h"

namespace dart {
namespace embedder {

// Initialize all subsystems of the embedder.
//
// Must be called before the `Dart_Initialize()` call to initialize the
// Dart VM.
//
// Returns true on success and false otherwise, in which case error would
// contain error message.
DART_WARN_UNUSED_RESULT bool InitOnce(char** error);

// Cleans up all subsystems of the embedder.
//
// Must be called after the `Dart_Cleanup()` call to initialize the
// Dart VM.
void Cleanup();

// Common arguments that are passed to isolate creation callback and to
// API methods that create isolates.
struct IsolateCreationData {
  // URI for the main script that will be running in the isolate.
  const char* script_uri;

  // Advisory name of the main method that will be run by isolate.
  // Only used for error messages.
  const char* main;

  // Isolate creation flags. Might be absent.
  Dart_IsolateFlags* flags;

  // Isolate group callback data.
  void* isolate_group_data;

  // Isolate callback data.
  void* isolate_data;
};

// Create and initialize kernel-service isolate. This method should be used
// when VM invokes isolate creation callback with DART_KERNEL_ISOLATE_NAME as
// script_uri.
// The isolate is created from the given snapshot (might be kernel data or
// app-jit snapshot).
DART_WARN_UNUSED_RESULT Dart_Isolate
CreateKernelServiceIsolate(const IsolateCreationData& data,
                           const uint8_t* buffer,
                           intptr_t buffer_size,
                           char** error);

// Service isolate configuration.
struct VmServiceConfiguration {
  enum {
    kBindHttpServerToAFreePort = 0,
    kDoNotAutoStartHttpServer = -1
  };

  // Address to which HTTP server will be bound.
  const char* ip;

  // Default port. See enum above for special values.
  int port;

  // If non-null, connection information for the VM service will be output to a
  // file in JSON format at the location specified.
  const char* write_service_info_filename;

  // TODO(vegorov) document these ones.
  bool dev_mode;
  bool deterministic;
  bool disable_auth_codes;
};

// Create and initialize vm-service isolate from the given AOT snapshot, which
// is expected to contain all necessary 'vm-service' libraries.
// This method should be used when VM invokes isolate creation callback with
// DART_VM_SERVICE_ISOLATE_NAME as script_uri.
DART_WARN_UNUSED_RESULT Dart_Isolate
CreateVmServiceIsolate(const IsolateCreationData& data,
                       const VmServiceConfiguration& config,
                       const uint8_t* isolate_data,
                       const uint8_t* isolate_instr,
                       char** error);

// Create and initialize vm-service isolate from the given kernel binary, which
// is expected to contain all necessary 'vm-service' libraries.
// This method should be used when VM invokes isolate creation callback with
// DART_VM_SERVICE_ISOLATE_NAME as script_uri.
DART_WARN_UNUSED_RESULT Dart_Isolate
CreateVmServiceIsolateFromKernel(const IsolateCreationData& data,
                                 const VmServiceConfiguration& config,
                                 const uint8_t* kernel_buffer,
                                 intptr_t kernel_buffer_size,
                                 char** error);

}  // namespace embedder
}  // namespace dart

#endif  // RUNTIME_INCLUDE_DART_EMBEDDER_API_H_
