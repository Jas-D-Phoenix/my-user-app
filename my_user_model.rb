require 'sqlite3'

class User
    attr_accessor :id, :firstname, :lastname, :age, :password , :email
    def initialize (id=0, firstname, lastname, age, password , email)
        @firstname=firstname
        @lastname=lastname
        @age=age 
        @password=password 
        @email=email
        @id=id
    end

    def self.conn()
        begin
            @db_conn = SQLite3::Database.open 'db.sql'
            @db_conn = SQLite3::Database.new 'db.sql' if !@db_conn
            @db_conn.results_as_hash = true
            @db_conn.execute "CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, firstname STRING, lastname STRING, age INTEGER, password STRING, email STRING)"
            return @db_conn
        rescue SQLite3::Exception => e
            p "Error Ocurred: "
            p e
        end
    end 

    def self.create(user_info)
        @firstname = user_info[:firstname]
        @lastname = user_info[:lastname]
        @age = user_info[:age] 
        @password = user_info[:password] 
        @email = user_info[:email]
        

        @db_conn = self.conn
        @db_conn.execute "INSERT INTO users(firstname, lastname, age, password, email) VALUES(?,?,?,?,?)", @firstname, @lastname, @age, @password, @email
        user=User.new(@firstname, @lastname, @age, @password, @email)
        user.id = @db_conn.last_insert_row_id
        @db_conn.close
        return user
    end 

    def self.find(user_id)
        @db_conn = self.conn
        user = @db_conn.execute "SELECT * FROM users WHERE id = ?", user_id
        user_info=User.new(user[0]["firstname"], user[0]["lastname"], user[0]["age"],user[0]["password"], user[0]["email"])
        @db_conn.close
        return user_info
    end
     
    def self.all()
        @db_conn = self.conn()
        user = @db_conn.execute "SELECT * FROM users"
        @db_conn.close
        return user
    end 

    def self.update(user_id, attribute, value)
        @db_conn = self.conn
        @db_conn.execute "UPDATE users SET #{attribute} = ? WHERE id = ? ", value, user_id
        user = @db_conn.execute "SELECT * FROM users where id = ? ", user_id
        @db_conn.close
        return user
    end

    def self.destroy(user_id)
        @db_conn=self.conn()
        deleted_user=@db_conn.execute "DELETE FROM users WHERE id=#{user_id}"
        @db_conn.close
        return deleted_user 
    end 

    def self.authenticate(password, email)
        @db_conn = self.conn
        user = @db_conn.execute "SELECT * FROM users WHERE email = ? AND password = ?", email, password
        @db_conn.close
        return user 
    end
end 
