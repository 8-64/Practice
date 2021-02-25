#!/usr/bin/perl

use v5.23;
use feature ':all';
use warnings; no warnings 'experimental';

# Have it been supplied with a readable file as an argument?
# If yes - open it, otherwise try example in the DATA section
my $LOG;
my $log_file = $ARGV[0];
if (defined $log_file and -r -f $log_file) {
    open ($LOG, '<', $log_file) or die ("Can't open [$log_file] - [$!]");
} else {
    $LOG = *DATA;
}

&SplitLog($LOG);

exit 0;

sub SplitLog ($LOG) {
    # File to store unidentified part(s)
    open (my $UNIDENTIFIED, '+>>', 'unidentified.log') or die ("Can't open [unidentified.log] - [$!]");

    # Regex to parse the line
    my $rx = qr/
        ^
        .*
        \[ (INFO|WARN|SEVERE) \]
        \s+
        \(
            (?<Thread_id> [[:alnum:]-]+ )
        \)
        \s+
    /x;

    # Process the log file line by line
    my ($LOG_PART, $log_part_open);
    while (my $line = readline $LOG) {
        $line =~ $rx;
        my $thread_id = $+{Thread_id};

        $log_part_open = fileno($LOG_PART // 0);

        # Case when thread id is in the line
        if (defined $thread_id) {
            close $LOG_PART if $log_part_open;
            open ($LOG_PART, '+>>', "$thread_id.log") or die ("Can't open [$thread_id.log] - [$!]");
            print $LOG_PART $line;

        # Case when there is no thread id on the line but there is an open file with thread id
        } elsif ($log_part_open) {
            print $LOG_PART $line;

        # Case when there is garbage at the start of the file
        } else {
            print $UNIDENTIFIED $line;
        }
    }

    close $LOG_PART if $log_part_open;
    close $UNIDENTIFIED;
    close $LOG;
}

# NOTE: I haven't copied the sample of the log file, so here is an approximation of it:
__DATA__
Some garbage data at the beginning:
An error occurred at line: 34 in the jsp file: /testmysql.jsp
ds cannot be resolved
31: 		    try { c.close(); } catch (SQLException e) { }
32: 		} finally {
33: 		    // properly release our connection
34: 		    DataSourceUtils.releaseConnection(c, ds);
35: 		}
36: 	}
37: 	catch (SQLException s)

Jun 29, 2008 11:16:20 AM org.apache.catalina.core.ApplicationContext log [INFO] (thread-id-1) ContextListener: contextInitialized()
Jun 29, 2008 11:16:20 AM org.apache.catalina.core.ApplicationContext log [INFO] (thread-id-123) SessionListener: contextInitialized()
Jun 29, 2008 11:22:43 AM org.apache.catalina.core.StandardWrapperValve [SEVERE] (thread-id-123) Servlet.service() for servlet jsp threw exception
org.apache.jasper.JasperException: /testmysql.jsp(3,4) Invalid directive
	at org.apache.jasper.compiler.DefaultErrorHandler.jspError(DefaultErrorHandler.java:40)
	at org.apache.jasper.compiler.ErrorDispatcher.dispatch(ErrorDispatcher.java:407)
	at org.apache.jasper.compiler.ErrorDispatcher.jspError(ErrorDispatcher.java:88)
	at org.apache.jasper.compiler.Parser.parseDirective(Parser.java:506)
	at org.apache.jasper.compiler.Parser.parseElements(Parser.java:1433)
	at org.apache.jasper.compiler.Parser.parse(Parser.java:133)
	at org.apache.jasper.compiler.ParserController.doParse(ParserController.java:216)
	at org.apache.jasper.compiler.ParserController.parse(ParserController.java:103)
	at org.apache.jasper.compiler.Compiler.generateJava(Compiler.java:153)
	at org.apache.jasper.compiler.Compiler.compile(Compiler.java:314)
...
Jun 29, 2008 11:23:02 AM org.apache.catalina.core.StandardWrapperValve invoke [SEVERE] (thread-id-1) Servlet.service() for servlet jsp threw exception
org.apache.jasper.JasperException: Unable to compile class for JSP:
An error occurred at line: 13 in the jsp file: /testmysql.jsp
Syntax error, insert "AssignmentOperator Expression" to complete Assignment
10: Connection dbconn;
11: ResultSet results;
12: PreparedStatement sql;
13: TRY
14: {
15: 	Class.forname("com.mysql.jdbc.Driver").newInstance();
16: 	TRY
...
Jun 29, 2008 11:46:10 AM org.apache.catalina.core.StandardWrapperValve invoke [SEVERE] (thread-id-2) Servlet.service() for servlet jsp threw exception
org.apache.jasper.JasperException: Unable to compile class for JSP:
An error occurred at line: 31 in the jsp file: /testmysql.jsp
c cannot be resolved
28: 			}
29: 		} catch (SQLException ex) {
30: 		    ex.printStackTrace();
31: 		    try { c.close(); } catch (SQLException e) { }
32: 		} finally {
33: 		    // properly release our connection
34: 		    DataSourceUtils.releaseConnection(c, ds);
Jun 29, 2008 11:47:25 AM org.apache.catalina.core.StandardWrapperValve invoke [SEVERE] (thread-id-2) Servlet.service() for servlet jsp threw exception
org.apache.jasper.JasperException: Unable to compile class for JSP:

An error occurred at line: 103 in the generated java file
Syntax error on token "catch", Identifier expected

An error occurred at line: 105 in the generated java file
out cannot be resolved

An error occurred at line: 105 in the generated java file
_jspx_out cannot be resolved

An error occurred at line: 106 in the generated java file
out cannot be resolved
...

Jun 29, 2008 1:26:34 PM org.apache.catalina.core.ApplicationContext log [INFO] (thread-id-1) SessionListener: contextDestroyed()
Jun 29, 2008 1:26:34 PM org.apache.catalina.core.ApplicationContext log [INFO] (thread-id-3) ContextListener: contextDestroyed()
