/* -*- Mode: C; tab-width: 8; indent-tabs-mode: t; c-basic-offset: 8 -*- */
/*
*  Authors: Rolf Bjarne Kvinge
*
*  Copyright (C) 2021 Microsoft Corp.
*
*/

#if defined (CORECLR_RUNTIME)

#include "product.h"
#include "xamarin/xamarin.h"
#include "xamarin/coreclr-bridge.h"

#include "coreclrhost.h"

unsigned int coreclr_domainId = 0;
void *coreclr_handle = NULL;

void
xamarin_bridge_setup ()
{
}

void
xamarin_bridge_initialize ()
{
}

bool
xamarin_bridge_vm_initialize (int propertyCount, const char **propertyKeys, const char **propertyValues)
{
	int rv;

	const char *executablePath = [[[[NSBundle mainBundle] executableURL] path] UTF8String];
	rv = coreclr_initialize (
		executablePath,
		xamarin_executable_name,
		propertyCount,
		propertyKeys,
		propertyValues,
		&coreclr_handle,
		&coreclr_domainId
		);

	LOG_CORECLR (stderr, "xamarin_vm_initialize (%i, %p, %p): rv: %i domainId: %i handle: %p\n", propertyCount, propertyKeys, propertyValues, rv, coreclr_domainId, coreclr_handle);

	return rv == 0;
}

void
xamarin_handle_bridge_exception (GCHandle gchandle, const char *method)
{
	if (gchandle == INVALID_GCHANDLE)
		return;

	if (method == NULL)
		method = "<unknown method";

	fprintf (stderr, "%s threw an exception: %p\n", method, gchandle);
	xamarin_assertion_message ("%s threw an exception: %p", method, gchandle);
}

typedef void (*xamarin_runtime_initialize_decl)(struct InitializationOptions* options);
void
xamarin_bridge_call_runtime_initialize (struct InitializationOptions* options, GCHandle* exception_gchandle)
{
	void *del = NULL;
	int rv = coreclr_create_delegate (coreclr_handle, coreclr_domainId, PRODUCT ", Version=0.0.0.0", "ObjCRuntime.Runtime", "Initialize", &del);
	if (rv != 0)
		xamarin_assertion_message ("xamarin_bridge_call_runtime_initialize: failed to create delegate: %i\n", rv);

	xamarin_runtime_initialize_decl runtime_initialize = (xamarin_runtime_initialize_decl) del;
	runtime_initialize (options);
}

void
xamarin_bridge_register_product_assembly (GCHandle* exception_gchandle)
{
	xamarin_open_and_register (PRODUCT_DUAL_ASSEMBLY, exception_gchandle);
}

MonoClass *
xamarin_get_nsnumber_class ()
{
	xamarin_assertion_message ("The method %s it not implemented yet for CoreCLR", __func__);
}

MonoClass *
xamarin_get_nsvalue_class ()
{
	xamarin_assertion_message ("The method %s it not implemented yet for CoreCLR", __func__);
}

MonoClass *
xamarin_get_inativeobject_class ()
{
	xamarin_assertion_message ("The method %s it not implemented yet for CoreCLR", __func__);
}

MonoClass *
xamarin_get_nsobject_class ()
{
	xamarin_assertion_message ("The method %s it not implemented yet for CoreCLR", __func__);
}

MonoClass *
xamarin_get_nsstring_class ()
{
	xamarin_assertion_message ("The method %s it not implemented yet for CoreCLR", __func__);
}

MonoClass *
xamarin_get_runtime_class ()
{
	xamarin_assertion_message ("The method %s it not implemented yet for CoreCLR", __func__);
}

#endif // CORECLR_RUNTIME