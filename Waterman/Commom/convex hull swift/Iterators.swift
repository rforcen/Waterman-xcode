//
//  Iterators.swift
//  Waterman
//
//  Created by asd on 21/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

// Base class Iterator
class BaseIterator<T> : Sequence, IteratorProtocol {
    typealias  Element = T
    public enum NextTypes {  case nextLoop, nextNil  }
    var loopType : NextTypes
    var from : T? = nil, to : T? = nil
    var finished : Bool = false
    var count : Int {
        get {
            var n : Int = 0
            while let _ = next() { n+=1 }
            return n
        }
    }
    
    init(_ from : T?, _ to : T?, _ loopType:NextTypes) {
        self.from=from
        self.to=to
        self.loopType=loopType
    }
    
    func makeIterator() -> BaseIterator {
        return self
    }
    func next() -> BaseIterator.Element? {
        switch loopType {
        case .nextLoop:
            return next2loop()
        case .nextNil:
            return next2nil()
        }
    }
    
    private func nextFrom() { // from = from!next
        switch from {
        case is Face     : from = (from as! Face).next as? T
        case is Vertex   : from = (from as! Vertex).next as? T
        case is HalfEdge : from = (from as! HalfEdge).next as? T
        default:  break
        }
    }
    
    func next2nil() -> BaseIterator.Element? { // next 2 nil
        let v=from
        if (v != nil) { nextFrom() }
        return v
    }
    
    func next2loop() ->BaseIterator.Element? { // next from == to
        if(finished) { return nil } // skip first from===to
        
        let f=from
        nextFrom()
        
        finished = ( to as AnyObject === from as AnyObject )
        return f
    }
}

// from -> to
class LoopIterator<T> : BaseIterator<T> {
    init(_ from: T?, _ to: T?)  {  super.init(from, to, .nextLoop)  }
}

// from -> nil
class Base2NilIterator<T> : BaseIterator<T> {
    init(_ from: T?)            {  super.init(from, nil, .nextNil)   }
}


// HalfEdge from -> from loop by next
class HalfEdgeLoopIterator: LoopIterator<HalfEdge> {
    init(start:HalfEdge?) {
        super.init(start, start)
    }
}

// HalfEdge from -> to by next
class HalfEdgeRangeIterator : LoopIterator<HalfEdge> {
    init(from:HalfEdge?, to:HalfEdge?) {
        super.init(from, to)
    }
}


// HalfEdge next.next Loop iterator: from start.next.next to start w/ getNext()
class HalfEdgeNNLoopIterator : LoopIterator<HalfEdge>{
    init(start:HalfEdge?) {
        super.init(start?.next?.next, start)
    }
}


// Vertex from -> nil, next
class VertexIterator : Base2NilIterator<Vertex> {
    override init(_ vtx:Vertex?) {
        super.init(vtx)
    }
}

// Face iterator: from start to nil w/ next
class FaceIterator : Base2NilIterator<Face> {
    init(_ face:Face) {
        super.init(face)
    }
}

// func iterator, from funcCall to nil by funcCalla
class FuncIterator<T> : Sequence, IteratorProtocol {
    typealias Element = T
    typealias FuncType = ()->T?
    
    var funcCall : FuncType
    
    init(funcCall : @escaping FuncType)  {  self.funcCall = funcCall    }
    func makeIterator() -> FuncIterator  {  return self                 }
    func next() -> FuncIterator.Element? {  return funcCall()           }
}

// new instance iterator, creates count times new DIFFERENT instances
class InstanceRepeater<T> : Sequence, IteratorProtocol {
    typealias Element = T
    var item : T? = nil
    var count : Int = 0
    
    init(_ item : T, _ count : Int)  {
        self.count = count
        self.item = item
    }
    func makeIterator() -> InstanceRepeater  {  return self                 }
    func next() -> InstanceRepeater.Element? {
        if (count == 0) { return nil }
        count -= 1
        
        switch item {
        case is Face?     : return Face() as? T
        case is Vertex?   : return Vertex() as? T
        case is Point3d?  : return Point3d() as? T
        default:  return nil
        }
    }
}

// generate 'times' different instances of 'instance', Array<T>(repeating: T(), count: n) generates n copies of the SAME instance
func multiplyInstances<T>(instance: T, count:Int) -> [T] {
    var vi = [T]()
    for _ in 0..<count {
        var item : T? = instance
        switch item {
        case is Face?     : item = Face() as? T
        case is Vertex?   : item = Vertex() as? T
        case is Point3d?  : item = Point3d() as? T
        default:  assert(true, "wrong generic type")
        }
        vi.append(item!)
    }
    return vi
}
