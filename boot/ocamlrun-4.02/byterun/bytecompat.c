/***********************************************************************/
/*                                                                     */
/*                                OCaml                                */
/*                                                                     */
/*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         */
/*                                                                     */
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  en Automatique.  All rights reserved.  This file is distributed    */
/*  under the terms of the GNU Library General Public License, with    */
/*  the special exception on linking described in file ../LICENSE.     */
/*                                                                     */
/***********************************************************************/

/* Implements support for former exception format, for bytecode
   compatibility */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "backtrace.h"
#include "callback.h"
#include "debugger.h"
#include "fail.h"
#include "misc.h"
#include "mlvalues.h"
#include "memory.h"
#include "alloc.h"
#include "printexc.h"

struct stringbuf {
  char * ptr;
  char * end;
  char data[256];
};

static void add_char(struct stringbuf *buf, char c)
{
  if (buf->ptr < buf->end) *(buf->ptr++) = c;
}

static void add_string(struct stringbuf *buf, char *s)
{
  int len = strlen(s);
  if (buf->ptr + len > buf->end) len = buf->end - buf->ptr;
  if (len > 0) memmove(buf->ptr, s, len);
  buf->ptr += len;
}

CAMLexport char * Caml1999X008_caml_format_exception(value exn)
{
  mlsize_t start, i;
  value bucket, v;
  struct stringbuf buf;
  char intbuf[64];
  char * res;

  buf.ptr = buf.data;
  buf.end = buf.data + sizeof(buf.data) - 1;
  add_string(&buf, String_val(Field(Field(exn, 0), 0)));
  if (Wosize_val(exn) >= 2) {
    /* Check for exceptions in the style of Match_failure and Assert_failure */
    if (Wosize_val(exn) == 2 &&
        Is_block(Field(exn, 1)) &&
        Tag_val(Field(exn, 1)) == 0 &&
        caml_is_special_exception(Field(exn, 0))) {
      bucket = Field(exn, 1);
      start = 0;
    } else {
      bucket = exn;
      start = 1;
    }
    add_char(&buf, '(');
    for (i = start; i < Wosize_val(bucket); i++) {
      if (i > start) add_string(&buf, ", ");
      v = Field(bucket, i);
      if (Is_long(v)) {
        sprintf(intbuf, "%" ARCH_INTNAT_PRINTF_FORMAT "d", Long_val(v));
        add_string(&buf, intbuf);
      } else if (Tag_val(v) == String_tag) {
        add_char(&buf, '"');
        add_string(&buf, String_val(v));
        add_char(&buf, '"');
      } else {
        add_char(&buf, '_');
      }
    }
    add_char(&buf, ')');
  }
  *buf.ptr = 0;              /* Terminate string */
  i = buf.ptr - buf.data + 1;
  res = malloc(i);
  if (res == NULL) return NULL;
  memmove(res, buf.data, i);
  return res;
}



CAMLexport void Caml1999X008_caml_raise_constant(value tag)
{
  CAMLparam1 (tag);
  CAMLlocal1 (bucket);

  bucket = caml_alloc_small (1, 0);
  Field(bucket, 0) = tag;
  caml_raise(bucket);
  CAMLnoreturn;
}

/* Problem: we can't use [caml_raise_constant], because it allocates and
   we're out of memory... Here, we allocate statically the exn bucket
   for [Out_of_memory]. */

static struct {
  header_t hdr;
  value exn;
} out_of_memory_bucket = { 0, 0 };

CAMLexport void Caml1999X008_caml_raise_out_of_memory(void)
{
  if (out_of_memory_bucket.exn == 0)
    caml_fatal_error
      ("Fatal error: out of memory while raising Out_of_memory\n");
  caml_raise((value) &(out_of_memory_bucket.exn));
}
