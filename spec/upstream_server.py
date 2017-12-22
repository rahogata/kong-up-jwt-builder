from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer

class HelperHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        global rootnode
        try:
	    self.send_response(200)
	    userid = self.headers.getheader('x-authenticated_userid')
	    if userid:
            	self.send_header('x-authenticated_userid', userid)
            self.end_headers()
            return
        except :
            pass

def main():
    try:
        server = HTTPServer(('', 80), HelperHandler)
        print 'Started HTTP Server...:)'
        server.serve_forever()
    except KeyboardInterrupt:
        print '^C received, shutting down server'
        server.socket.close()

if __name__ == '__main__':
    main()

