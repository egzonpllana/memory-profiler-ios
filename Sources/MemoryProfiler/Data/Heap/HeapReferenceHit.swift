//
//  HeapReferenceHit.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Foundation

/// One pointer to a scan target found inside a heap block. Addresses are disguised.
struct HeapReferenceHit {

    /// The referring block.
    let block: DisguisedAddress

    /// Size of the referring block in bytes.
    let blockSize: UInt64

    /// Masked first word of the block; a class address when the block is an object.
    let blockClass: UInt

    /// Byte offset of the pointer inside the block.
    let offset: Int

    /// The target the pointer refers to.
    let target: DisguisedAddress
}
