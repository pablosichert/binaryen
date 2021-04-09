;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s -all --dse -S -o - | filecheck %s

(module
 (type $A (struct (field (mut i32))))
 (type $B (struct (field (mut f64))))

 (global $global$0 (mut i32) (i32.const 0))
 (global $global$1 (mut i32) (i32.const 0))

 ;; CHECK:      (func $simple-param (param $x (ref $A))
 ;; CHECK-NEXT:  (block
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (local.get $x)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (i32.const 10)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (local.get $x)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (i32.const 20)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 30)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $simple-param (param $x (ref $A))
  (struct.set $A 0
   (local.get $x)
   (i32.const 10)
  )
  (struct.set $A 0
   (local.get $x)
   (i32.const 20)
  )
  ;; the last store escapes to the outside, and cannot be modified
  (struct.set $A 0
   (local.get $x)
   (i32.const 30)
  )
 )

 ;; TODO: test with locals when non-nullable locals are possible

 ;; CHECK:      (func $simple-fallthrough (param $x (ref $A))
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (block $block (result (ref $A))
 ;; CHECK-NEXT:    (local.get $x)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (i32.const 10)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (block $block0 (result (ref $A))
 ;; CHECK-NEXT:    (local.get $x)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (i32.const 20)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $simple-fallthrough (param $x (ref $A))
  (struct.set $A 0
   (block (result (ref $A))
    (local.get $x)
   )
   (i32.const 10)
  )
  (struct.set $A 0
   (block (result (ref $A))
    (local.get $x)
   )
   (i32.const 20)
  )
 )

 ;; CHECK:      (func $simple-use (param $x (ref $A))
 ;; CHECK-NEXT:  (block
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (local.get $x)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (i32.const 10)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 20)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (struct.get $A 0
 ;; CHECK-NEXT:    (local.get $x)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 30)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $simple-use (param $x (ref $A))
  (struct.set $A 0
   (local.get $x)
   (i32.const 10)
  )
  (struct.set $A 0
   (local.get $x)
   (i32.const 20)
  )
  (drop
   (struct.get $A 0
    (local.get $x)
   )
  )
  (struct.set $A 0
   (local.get $x)
   (i32.const 30)
  )
 )

 ;; CHECK:      (func $two-types (param $x (ref $A)) (param $y (ref $B))
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 10)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $B 0
 ;; CHECK-NEXT:   (local.get $y)
 ;; CHECK-NEXT:   (f64.const 20)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 30)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $two-types (param $x (ref $A)) (param $y (ref $B))
  (struct.set $A 0
   (local.get $x)
   (i32.const 10)
  )
  ;; the simple analysis currently gives up on a set we cannot easily classify
  (struct.set $B 0
   (local.get $y)
   (f64.const 20)
  )
  (struct.set $A 0
   (local.get $x)
   (i32.const 30)
  )
 )

 ;; CHECK:      (func $two-types-get (param $x (ref $A)) (param $y (ref $B))
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 10)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (struct.get $B 0
 ;; CHECK-NEXT:    (local.get $y)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 30)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $two-types-get (param $x (ref $A)) (param $y (ref $B))
  (struct.set $A 0
   (local.get $x)
   (i32.const 10)
  )
  ;; the simple analysis currently gives up on a set we cannot easily classify
  (drop
   (struct.get $B 0
    (local.get $y)
   )
  )
  (struct.set $A 0
   (local.get $x)
   (i32.const 30)
  )
 )

 (func $foo)

 ;; CHECK:      (func $call (param $x (ref $A))
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 10)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (call $foo)
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 30)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $call (param $x (ref $A))
  (struct.set $A 0
   (local.get $x)
   (i32.const 10)
  )
  ;; the analysis gives up on a call
  (call $foo)
  (struct.set $A 0
   (local.get $x)
   (i32.const 30)
  )
 )

 ;; CHECK:      (func $through-branches (param $x (ref $A))
 ;; CHECK-NEXT:  (block
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (local.get $x)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (i32.const 10)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (nop)
 ;; CHECK-NEXT:   (nop)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 30)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $through-branches (param $x (ref $A))
  (struct.set $A 0
   (local.get $x)
   (i32.const 10)
  )
  ;; the analysis is not confused by branching
  (if (i32.const 1)
   (nop)
   (nop)
  )
  (struct.set $A 0
   (local.get $x)
   (i32.const 30)
  )
 )

 ;; CHECK:      (func $just-one-branch-trample (param $x (ref $A))
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 10)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (struct.set $A 0
 ;; CHECK-NEXT:    (local.get $x)
 ;; CHECK-NEXT:    (i32.const 20)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (nop)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $just-one-branch-trample (param $x (ref $A))
  (struct.set $A 0
   (local.get $x)
   (i32.const 10)
  )
  ;; a trample on just one branch is not enough
  (if (i32.const 1)
   (struct.set $A 0
    (local.get $x)
    (i32.const 20)
   )
   (nop)
  )
 )

 ;; CHECK:      (func $just-one-branch-bad (param $x (ref $A))
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 10)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (call $foo)
 ;; CHECK-NEXT:   (nop)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 30)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $just-one-branch-bad (param $x (ref $A))
  (struct.set $A 0
   (local.get $x)
   (i32.const 10)
  )
  ;; an unknown interaction on one branch is enough to make us give up
  (if (i32.const 1)
   (call $foo)
   (nop)
  )
  (struct.set $A 0
   (local.get $x)
   (i32.const 30)
  )
 )

 ;; CHECK:      (func $simple-in-branches (param $x (ref $A))
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (block $block
 ;; CHECK-NEXT:    (block
 ;; CHECK-NEXT:     (drop
 ;; CHECK-NEXT:      (local.get $x)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (drop
 ;; CHECK-NEXT:      (i32.const 10)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (struct.set $A 0
 ;; CHECK-NEXT:     (local.get $x)
 ;; CHECK-NEXT:     (i32.const 20)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (block $block1
 ;; CHECK-NEXT:    (block
 ;; CHECK-NEXT:     (drop
 ;; CHECK-NEXT:      (local.get $x)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (drop
 ;; CHECK-NEXT:      (i32.const 30)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (struct.set $A 0
 ;; CHECK-NEXT:     (local.get $x)
 ;; CHECK-NEXT:     (i32.const 40)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $simple-in-branches (param $x (ref $A))
  (if (i32.const 1)
   (block
    (struct.set $A 0
     (local.get $x)
     (i32.const 10)
    )
    (struct.set $A 0
     (local.get $x)
     (i32.const 20)
    )
   )
   (block
    (struct.set $A 0
     (local.get $x)
     (i32.const 30)
    )
    (struct.set $A 0
     (local.get $x)
     (i32.const 40)
    )
   )
  )
 )

 ;; CHECK:      (func $different-refs-same-type (param $x (ref $A)) (param $y (ref $A))
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 10)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $y)
 ;; CHECK-NEXT:   (i32.const 20)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (struct.set $A 0
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (i32.const 30)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $different-refs-same-type (param $x (ref $A)) (param $y (ref $A))
  (struct.set $A 0
   (local.get $x)
   (i32.const 10)
  )
  (struct.set $A 0
   (local.get $y)
   (i32.const 20)
  )
  ;; the last store escapes to the outside, and cannot be modified
  (struct.set $A 0
   (local.get $x)
   (i32.const 30)
  )
 )

 ;; CHECK:      (func $no-basic-blocks
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT: )
 (func $no-basic-blocks
  (unreachable)
 )

 ;; CHECK:      (func $global
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (i32.const 10)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (global.set $global$1
 ;; CHECK-NEXT:   (i32.const 20)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (global.set $global$0
 ;; CHECK-NEXT:   (i32.const 30)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $global
  ;; globals are optimized as well, and we have more precise data there than on
  ;; GC references - aliasing is impossible.
  (global.set $global$0
   (i32.const 10)
  )
  (global.set $global$1
   (i32.const 20)
  )
  (global.set $global$0
   (i32.const 30)
  )
 )

 ;; CHECK:      (func $global-trap
 ;; CHECK-NEXT:  (global.set $global$0
 ;; CHECK-NEXT:   (i32.const 10)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (unreachable)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (global.set $global$0
 ;; CHECK-NEXT:   (i32.const 20)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $global-trap
  (global.set $global$0
   (i32.const 10)
  )
  ;; a trap (even conditional) prevents our optimizations, global state may be
  ;; observed if another export is called later after the trap.
  (if
   (i32.const 1)
   (unreachable)
  )
  (global.set $global$0
   (i32.const 20)
  )
 )

 ;; TODO: test try throwing
)
