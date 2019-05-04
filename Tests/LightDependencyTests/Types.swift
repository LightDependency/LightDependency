class Type1 {
    var value: String
    init(_ value: String = "1") {
        self.value = value
    }
}

class Type2 {
    var value: String
    
    init(_ value: String = "2") {
        self.value = value
    }
}

class Type3 {
    var value: String
    
    init(_ value: String = "3") {
        self.value = value
    }
}

class Type4 {
    var value: String
    
    init(_ value: String = "4") {
        self.value = value
    }
}

class Type5 {
    var value: String
    
    init(_ value: String = "5") {
        self.value = value
    }
}

class Type6 {
    var value: String
    
    init(_ value: String = "6") {
        self.value = value
    }
}

class Type7 {
    var value: String
    
    init(_ value: String = "7") {
        self.value = value
    }
}

class ResultType {
    var value: String
    
    init(_ value: String) {
        self.value = value
    }
    
    init(_ t1: Type1) {
        value = t1.value
    }
    
    init(_ t1: Type1, _ t2: Type2) {
        value = [t1.value, t2.value].joined(separator: " ")
    }
    
    init(_ t1: Type1, _ t2: Type2, _ t3: Type3) {
        value = [t1.value, t2.value, t3.value].joined(separator: " ")
    }
    
    init(_ t1: Type1, _ t2: Type2, _ t3: Type3, _ t4: Type4) {
        value = [t1.value, t2.value, t3.value, t4.value].joined(separator: " ")
    }
    
    init(_ t1: Type1, _ t2: Type2, _ t3: Type3, _ t4: Type4, _ t5: Type5) {
        value = [t1.value, t2.value, t3.value, t4.value, t5.value].joined(separator: " ")
    }
    
    init(_ t1: Type1, _ t2: Type2, _ t3: Type3, _ t4: Type4, _ t5: Type5, _ t6: Type6) {
        value = [t1.value, t2.value, t3.value, t4.value, t5.value, t6.value].joined(separator: " ")
    }
    
    init(_ t1: Type1, _ t2: Type2, _ t3: Type3, _ t4: Type4, _ t5: Type5, _ t6: Type6, _ t7: Type7) {
        value = [t1.value, t2.value, t3.value, t4.value, t5.value, t6.value, t7.value].joined(separator: " ")
    }
}
