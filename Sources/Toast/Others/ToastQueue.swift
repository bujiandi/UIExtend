//
//  ToastQueue.swift
//  Toast
//
//  Created by 招利 李 on 2017/8/17.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import Foundation


open class ToastQueue<Task:ToastBaseTask>: ExpressibleByArrayLiteral, Sequence {
    
    public typealias Element = Task

    public init() {}
    
    public required init(arrayLiteral elements: Element...) {
        queue = elements
    }
    
    internal lazy var queue:[Element] = { return [Element]() }()
    
    open var count: Int { return queue.count }
    
    open var capacity: Int { return queue.capacity }
    
    open func reserveCapacity(_ minimumCapacity: Int) {
        queue.reserveCapacity(minimumCapacity)
    }
    
    open func append<S>(contentsOf newElements: S) where S : Sequence, S.Iterator.Element == Element {
        queue.append(contentsOf: newElements)
    }
    
    open func append(_ newTask:Element) {
        queue.append(newTask)
    }
    
    open func insert(_ newTask:Element, at index:Int) {
        queue.insert(newTask, at: index)
    }
    
    open func remove(at index:Int) {
        queue.removeFirst()
        queue.remove(at: index)
    }
    
    open func removeAll(keepingCapacity keepCapacity: Bool = false) {
        queue.removeAll(keepingCapacity: keepCapacity)
    }
    
    
}

extension ToastQueue : Collection {
    
    open func removeFirst() -> Element {
        return queue.removeFirst()
    }
    
    open func removeLast() -> Element {
        return queue.removeLast()
    }
    
}

extension ToastQueue : MutableCollection {
    
    public typealias _Element = Task
    public typealias Index = Int
    public typealias SubSequence = ArraySlice<Task>
    public typealias Iterator =  IndexingIterator<Array<Task>>
    public typealias IndexDistance = Int
    
    public subscript(index:Int) -> Task {
        get { return queue[index] }
        set { queue[index] = newValue }
    }
    
    public var startIndex:Index { return 0 }
    public var endIndex:Index { return queue.count - 1 }
    
    public func makeIterator() -> IndexingIterator<Array<Task>> {
        return queue.makeIterator()
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        get { return queue[bounds] }
        set { queue[bounds] = newValue }
    }
    
    public func index(after i: Index) -> Index {
        return i + 1
    }
}

